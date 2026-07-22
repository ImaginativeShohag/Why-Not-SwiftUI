//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import IndexStoreDB

// MARK: - SemanticTypeResolver

/// Authoritative `ResolvedType` lookup backed by Xcode's IndexStoreDB.
///
/// The Swift compiler writes complete symbol information into the index store as it
/// builds each compilation unit. We open that store read-only, look up the symbol
/// occurrence at the source position of each `with:` argument, then decode the
/// symbol's mangled USR via `xcrun swift-demangle` to recover its full signature
/// (e.g. `Core.ItemInfo.getItemQty() -> Swift.Int`). The return / value type is
/// extracted from the signature and mapped to a `ResolvedType`.
///
/// **Precondition**: the user must have built the project in Xcode at least once
/// recently so that the index store at
/// `~/Library/Developer/Xcode/DerivedData/<workspace>-<hash>/Index.noindex/DataStore`
/// is populated and current. If the store is missing or stale, lookups simply
/// return `.unknown` and the call site keeps its literal-only baseline type.
public final class SemanticTypeResolver {
    private let index: IndexStoreDB
    private var demangleCache: [String: ResolvedType] = [:]
    private var occurrencesByFile: [String: [SymbolOccurrence]] = [:]
    private var freshnessCache: [String: Bool] = [:]

    /// File paths whose source is newer than the corresponding indexed unit.
    /// Populated as we encounter them so the CLI can report a clear warning.
    public private(set) var staleFilePaths: Set<String> = []

    /// Create a resolver bound to a specific index store.
    /// - Parameters:
    ///   - storePath: Absolute path to the Xcode index `DataStore` directory.
    ///   - databasePath: Writable scratch directory IndexStoreDB uses for its
    ///     internal LMDB cache. Must already exist (the caller creates it).
    ///   - libraryPath: Absolute path to `libIndexStore.dylib` shipped with the
    ///     active Xcode toolchain.
    public init(storePath: String, databasePath: String, libraryPath: String) throws {
        let library = try IndexStoreLibrary(dylibPath: libraryPath)
        self.index = try IndexStoreDB(
            storePath: storePath,
            databasePath: databasePath,
            library: library,
            waitUntilDoneInitializing: true,
            readonly: false,
            listenToUnitEvents: false
        )
        index.pollForUnitChangesAndWait(isInitialScan: true)
    }

    // MARK: - Lookup

    /// Resolve the type of the expression at the given source position, searching a
    /// range of acceptable columns. Useful when the SwiftSyntax column landed on the
    /// start of a member chain rather than on the rightmost identifier; we widen the
    /// search to find the actual member.
    /// - Parameters:
    ///   - filePath: Absolute path to the Swift file.
    ///   - line: 1-based line number.
    ///   - utf8ColumnRange: 1-based UTF-8 column range to search (matches SwiftSyntax's
    ///     `SourceLocationConverter` output).
    /// - Returns: The resolved type, or `.unknown` when no symbol is recorded in that
    ///   range (literals, expressions inside files Xcode didn't index, etc.).
    public func resolveType(
        at filePath: String,
        line: Int,
        utf8ColumnRange: ClosedRange<Int>
    ) -> ResolvedType {
        // Refuse to answer when the index is stale relative to the source — the
        // line numbers won't line up and we'd return data for unrelated code.
        guard isFileFresh(filePath: filePath) else { return .unknown }

        let occurrences = cachedOccurrences(filePath: filePath)
        let matches = occurrences.filter {
            $0.location.line == line && utf8ColumnRange.contains($0.location.utf8Column)
        }
        // Prefer the occurrence whose column is closest to the centre of the
        // requested range; ties broken by preferring resolvable kinds. The
        // centre is the SwiftSyntax-computed member-lookup column, so the
        // closest occurrence is the most likely to be the symbol we want.
        let centre = (utf8ColumnRange.lowerBound + utf8ColumnRange.upperBound) / 2
        let sorted = matches.sorted { a, b in
            let aResolvable = isResolvableSymbol(a.symbol.kind)
            let bResolvable = isResolvableSymbol(b.symbol.kind)
            if aResolvable != bResolvable { return aResolvable }
            return abs(a.location.utf8Column - centre) < abs(b.location.utf8Column - centre)
        }
        guard let occ = sorted.first else { return .unknown }
        return resolveType(forUSR: occ.symbol.usr, kind: occ.symbol.kind)
    }

    /// Returns `true` when the indexed unit for `filePath` is at least as new as
    /// the source file's modification date. Stale files are recorded so the CLI
    /// can surface a clear "rebuild required" warning.
    public func isFileFresh(filePath: String) -> Bool {
        if let cached = freshnessCache[filePath] { return cached }

        let attrs = try? FileManager.default.attributesOfItem(atPath: filePath)
        guard let sourceDate = attrs?[.modificationDate] as? Date else {
            // No source mtime — be conservative and treat as fresh.
            freshnessCache[filePath] = true
            return true
        }

        guard let unitDate = index.dateOfLatestUnitFor(filePath: filePath) else {
            // File isn't in the index at all — definitely "stale" from our POV.
            freshnessCache[filePath] = false
            staleFilePaths.insert(filePath)
            return false
        }

        // Allow a 1-second slack to account for filesystem timestamp granularity.
        let fresh = unitDate.timeIntervalSince(sourceDate) >= -1.0
        freshnessCache[filePath] = fresh
        if !fresh { staleFilePaths.insert(filePath) }
        return fresh
    }

    // MARK: - Internal

    private func cachedOccurrences(filePath: String) -> [SymbolOccurrence] {
        if let cached = occurrencesByFile[filePath] {
            return cached
        }
        let fresh = index.symbolOccurrences(inFilePath: filePath)
        occurrencesByFile[filePath] = fresh
        return fresh
    }

    private func isResolvableSymbol(_ kind: IndexSymbolKind) -> Bool {
        switch kind {
        case .instanceMethod, .classMethod, .staticMethod, .function,
             .instanceProperty, .classProperty, .staticProperty,
             .variable, .field, .parameter, .enumConstant, .constructor:
            return true
        default:
            return false
        }
    }

    private func resolveType(forUSR usr: String, kind: IndexSymbolKind) -> ResolvedType {
        if let cached = demangleCache[usr] { return cached }

        // Swift USRs start with `s:`; the compiler's mangled-name prefix is `$s`.
        guard usr.hasPrefix("s:") else {
            demangleCache[usr] = .unknown
            return .unknown
        }
        let mangled = "$s" + usr.dropFirst(2)

        guard let demangled = SemanticTypeResolver.runDemangle(mangled) else {
            demangleCache[usr] = .unknown
            return .unknown
        }

        let resolved = extractType(from: demangled, kind: kind)
        demangleCache[usr] = resolved
        return resolved
    }

    /// Subprocess-cached demangler. We invoke `xcrun swift-demangle` per
    /// distinct USR (and cache the result), so cost amortises across call sites.
    private static func runDemangle(_ mangled: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["swift-demangle", mangled]
        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }
        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        let raw = String(data: data, encoding: .utf8) ?? ""
        // Output is `$s... ---> Module.Type.method() -> ReturnType` (one per line).
        // We want everything after the first ` ---> ` on the first line.
        let firstLine = raw.components(separatedBy: "\n").first ?? raw
        if let arrow = firstLine.range(of: " ---> ") {
            return String(firstLine[arrow.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let trimmed = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
        // If demangle just echoed the input back, it failed.
        if trimmed == mangled || trimmed.isEmpty {
            return nil
        }
        return trimmed
    }

    /// Convert a demangled signature into a `ResolvedType`.
    /// - Functions/methods/initializers: parse the trailing `-> ReturnType`.
    /// - Properties / variables / parameters / fields: parse the trailing `: Type`.
    /// - Anything else: `.unknown`.
    func extractType(from signature: String, kind: IndexSymbolKind) -> ResolvedType {
        switch kind {
        case .instanceMethod, .classMethod, .staticMethod, .function, .constructor:
            return parseFunctionReturnType(signature)
        case .instanceProperty, .classProperty, .staticProperty,
             .variable, .field, .parameter, .enumConstant:
            return parsePropertyType(signature)
        default:
            return .unknown
        }
    }

    /// Parse `Module.Type.method(args) -> ReturnType` and return `ReturnType`.
    /// Uses the **last** ` -> ` token at the top brace/paren level so closure
    /// arrows inside parameter lists don't fool us.
    ///
    /// IndexStoreDB records a synthesized `getter:`/`setter:` accessor occurrence
    /// (kind `.instanceMethod`) at the same source position as every property read.
    /// A getter demangles as an *accessor* — `…title.getter : Swift.String` — with
    /// no `->` return arrow, so when no top-level arrow is present we fall back to
    /// the property `: Type` form. Without this, every property / computed-property
    /// `with:` argument resolved to `.unknown` and the linter went silent.
    private func parseFunctionReturnType(_ signature: String) -> ResolvedType {
        guard let returnType = topLevelTail(signature, separator: " -> ") else {
            return parsePropertyType(signature)
        }
        return mapTypeString(returnType)
    }

    /// Parse `Module.Type.name : Type` and return `Type`.
    ///
    /// Function/closure parameters demangle with a trailing context clause —
    /// `userName #1 : Swift.String in Module.Type.fn(...) -> ()` — so after taking
    /// the type that follows ` : ` we drop anything from a top-level ` in ` onward.
    private func parsePropertyType(_ declaration: String) -> ResolvedType {
        guard let typeStr = topLevelTail(declaration, separator: " : ") else {
            return .unknown
        }
        return mapTypeString(stripContextClause(typeStr))
    }

    /// Remove a trailing ` in <enclosing declaration>` clause (present on parameter
    /// demangles) by truncating at the first top-level ` in `. Leaves ordinary type
    /// strings untouched.
    private func stripContextClause(_ typeStr: String) -> String {
        guard let head = topLevelHead(typeStr, separator: " in ") else { return typeStr }
        return head
    }

    /// Find the suffix of `signature` after the *last* occurrence of `separator`
    /// at brace/paren depth 0. Returns `nil` if the separator never appears at
    /// depth 0.
    private func topLevelTail(_ signature: String, separator: String) -> String? {
        let scalars = Array(signature.unicodeScalars)
        let sepScalars = Array(separator.unicodeScalars)
        guard !sepScalars.isEmpty, scalars.count >= sepScalars.count else { return nil }

        var depth = 0
        var lastMatch: Int? = nil
        var i = 0
        while i <= scalars.count - sepScalars.count {
            let c = scalars[i]
            switch c {
            case "(", "[", "<", "{":
                depth += 1
                i += 1
                continue
            case ")", "]", ">", "}":
                depth = max(0, depth - 1)
                i += 1
                continue
            default:
                break
            }
            if depth == 0 {
                var matches = true
                for (j, sep) in sepScalars.enumerated() where scalars[i + j] != sep {
                    matches = false
                    break
                }
                if matches {
                    lastMatch = i + sepScalars.count
                    i += sepScalars.count
                    continue
                }
            }
            i += 1
        }

        guard let lastMatch else { return nil }
        let tail = String(String.UnicodeScalarView(scalars[lastMatch...]))
        return tail.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Return the prefix of `signature` BEFORE the *first* occurrence of `separator`
    /// at brace/paren depth 0, or `nil` when the separator never appears at depth 0.
    private func topLevelHead(_ signature: String, separator: String) -> String? {
        let scalars = Array(signature.unicodeScalars)
        let sepScalars = Array(separator.unicodeScalars)
        guard !sepScalars.isEmpty, scalars.count >= sepScalars.count else { return nil }

        var depth = 0
        var i = 0
        while i <= scalars.count - sepScalars.count {
            let c = scalars[i]
            switch c {
            case "(", "[", "<", "{":
                depth += 1
                i += 1
                continue
            case ")", "]", ">", "}":
                depth = max(0, depth - 1)
                i += 1
                continue
            default:
                break
            }
            if depth == 0 {
                var matches = true
                for (j, sep) in sepScalars.enumerated() where scalars[i + j] != sep {
                    matches = false
                    break
                }
                if matches {
                    let head = String(String.UnicodeScalarView(scalars[..<i]))
                    return head.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            i += 1
        }
        return nil
    }

    /// Normalise a Swift type-string from demangled output into a `ResolvedType`.
    /// Strips optionals (`?`, `!`, `Swift.Optional<T>`), peels well-known module
    /// prefixes (`Swift.Int` → `Int`), and maps the bare identifier to our
    /// internal classification.
    func mapTypeString(_ s: String) -> ResolvedType {
        var str = s.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip force-unwraps and optional suffixes at the outer level.
        while str.hasSuffix("?") || str.hasSuffix("!") {
            str = String(str.dropLast())
        }
        // Strip `Swift.Optional<X>` / `Optional<X>`.
        for prefix in ["Swift.Optional<", "Optional<"] {
            if str.hasPrefix(prefix), str.hasSuffix(">") {
                str = String(str.dropFirst(prefix.count).dropLast())
                break
            }
        }
        str = str.trimmingCharacters(in: .whitespacesAndNewlines)

        // Tuples are objects for `%@` purposes (or unknown — pick .unknown to
        // stay conservative, no Swift tuple bridges to NSObject).
        if str.hasPrefix("(") {
            return .unknown
        }

        // Array / Dictionary / generic-shaped types — handle a few common ones.
        if str.hasPrefix("[") || str.hasPrefix("Swift.Array<") || str.hasPrefix("Array<") {
            return .object
        }
        if str.hasPrefix("Swift.Dictionary<") || str.hasPrefix("Dictionary<") {
            return .object
        }
        if str.hasPrefix("Swift.Set<") || str.hasPrefix("Set<") {
            return .object
        }

        // Strip a single leading module prefix when present (e.g. `Swift.Int`,
        // `Foundation.NSString`, `CoreGraphics.CGFloat`). Generic type arguments
        // are handled above, so anything remaining with a dot is a qualified name.
        if let dotIndex = str.firstIndex(of: ".") {
            let possibleModule = String(str[..<dotIndex])
            let rest = String(str[str.index(after: dotIndex)...])
            if knownModulePrefixes.contains(possibleModule), !rest.contains(".") {
                str = rest
            }
        }

        switch str {
        case "String", "Substring", "StaticString", "NSString", "NSMutableString", "Character":
            return .string
        case "Int", "Int8", "Int16", "Int32", "Int64":
            return .integer
        case "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
            return .unsignedInteger
        case "Double", "Float", "Float32", "Float64", "CGFloat", "Decimal":
            return .floatingPoint
        case "Bool", "ObjCBool":
            return .boolean
        case "AnyObject", "NSObject", "NSNumber", "NSDate", "NSURL", "Any":
            return .object
        case "Never":
            return .unknown
        default:
            // Unknown custom type. We don't know whether it bridges to NSObject,
            // so we stay pessimistic — return `.unknown` so the linter doesn't
            // raise a false positive for `%@` use.
            return .unknown
        }
    }

    private let knownModulePrefixes: Set<String> = [
        "Swift", "Foundation", "CoreGraphics", "CoreFoundation",
        "UIKit", "AppKit", "ObjectiveC", "Darwin"
    ]
}

// MARK: - Index store discovery

/// Helper that finds Xcode's index store for a given project on disk.
public enum IndexStoreDiscovery {

    /// Locate the index store associated with the given project root by scanning
    /// `~/Library/Developer/Xcode/DerivedData/*/info.plist` for an entry whose
    /// `WorkspacePath` lives under the project root.
    ///
    /// Returns `nil` when no DerivedData folder references the project.
    public static func indexStorePath(forProjectAt projectPath: String) -> String? {
        guard let derivedDataDirs = derivedDataChildren() else { return nil }
        let projectAbsolute = (projectPath as NSString).standardizingPath

        var best: (path: String, mtime: Date)?

        for dir in derivedDataDirs {
            let infoPlist = (dir as NSString).appendingPathComponent("info.plist")
            guard let workspacePath = workspacePathFromInfoPlist(infoPlist) else { continue }
            let normalisedWorkspace = (workspacePath as NSString).standardizingPath
            // Workspace plist points at <project>/<X>.xcworkspace; the workspace
            // lives inside the project root.
            guard normalisedWorkspace.hasPrefix(projectAbsolute) else { continue }

            let indexDir = (dir as NSString).appendingPathComponent("Index.noindex")
            let storePath = (indexDir as NSString).appendingPathComponent("DataStore")
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: storePath, isDirectory: &isDirectory),
                  isDirectory.boolValue else { continue }

            // When multiple DerivedData folders match (e.g. multiple worktrees),
            // pick the one that was most recently touched.
            let mtime = (try? FileManager.default.attributesOfItem(atPath: storePath)[.modificationDate] as? Date) ?? .distantPast
            if let current = best {
                if mtime > current.mtime { best = (storePath, mtime) }
            } else {
                best = (storePath, mtime)
            }
        }

        return best?.path
    }

    /// Locate `libIndexStore.dylib` shipped with the active Xcode toolchain.
    public static func indexStoreLibraryPath() -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = ["--find", "swiftc"]
        let outPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = Pipe()
        guard (try? process.run()) != nil else { return nil }
        process.waitUntilExit()
        guard process.terminationStatus == 0 else { return nil }

        let data = outPipe.fileHandleForReading.readDataToEndOfFile()
        guard let swiftcPath = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !swiftcPath.isEmpty else { return nil }

        let binDir = (swiftcPath as NSString).deletingLastPathComponent
        let toolchain = (binDir as NSString).deletingLastPathComponent
        let libDir = (toolchain as NSString).appendingPathComponent("lib")
        let candidate = (libDir as NSString).appendingPathComponent("libIndexStore.dylib")
        return FileManager.default.fileExists(atPath: candidate) ? candidate : nil
    }

    /// Create a writable scratch directory for IndexStoreDB's internal LMDB cache.
    /// We don't want this to live forever, so we drop it in the user's caches dir
    /// under a deterministic per-project key.
    public static func databasePath(forProjectAt projectPath: String) throws -> String {
        let caches = (NSHomeDirectory() as NSString)
            .appendingPathComponent("Library/Caches/LocalizeKit/indexdb")
        let projectHash = projectPath.djbHash
        let projectDir = (caches as NSString).appendingPathComponent("p-\(projectHash)")
        try FileManager.default.createDirectory(
            atPath: projectDir,
            withIntermediateDirectories: true
        )
        return projectDir
    }

    // MARK: - Helpers

    private static func derivedDataChildren() -> [String]? {
        let derived = (NSHomeDirectory() as NSString)
            .appendingPathComponent("Library/Developer/Xcode/DerivedData")
        guard let children = try? FileManager.default.contentsOfDirectory(atPath: derived) else {
            return nil
        }
        return children.map { (derived as NSString).appendingPathComponent($0) }
    }

    private static func workspacePathFromInfoPlist(_ path: String) -> String? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        guard let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let dict = plist as? [String: Any],
              let workspacePath = dict["WorkspacePath"] as? String else { return nil }
        return workspacePath
    }
}

private extension String {
    /// Small portable DJB hash used only to produce stable per-project scratch dirs.
    var djbHash: String {
        var hash: UInt64 = 5381
        for byte in self.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return String(hash, radix: 16)
    }
}
