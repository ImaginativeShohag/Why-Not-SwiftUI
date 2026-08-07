//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftParser
import SwiftSyntax

/// Extracts localization strings from Swift source files using SwiftSyntax.
public final class StringExtractor {
    private let projectPath: String
    private let verbose: Bool

    public init(projectPath: String, verbose: Bool = false) {
        self.projectPath = projectPath
        self.verbose = verbose
    }

    /// Extract all localization strings from the project.
    public func extract() throws -> [ExtractedString] {
        var extractedStrings: [ExtractedString] = []
        let fileManager = FileManager.default

        let targetsPath = (projectPath as NSString).appendingPathComponent("Targets")

        guard fileManager.fileExists(atPath: targetsPath) else {
            throw ExtractionError.targetsDirectoryNotFound(path: targetsPath)
        }

        let moduleDirectories = try fileManager.contentsOfDirectory(atPath: targetsPath)
            .filter { moduleName in
                var isDirectory: ObjCBool = false
                let modulePath = (targetsPath as NSString).appendingPathComponent(moduleName)
                return fileManager.fileExists(atPath: modulePath, isDirectory: &isDirectory) && isDirectory.boolValue
            }

        if verbose {
            print("📦 Found \(moduleDirectories.count) modules")
        }

        // Extract `.localize` / `Text.localized` call sites. Argument types are
        // classified for literals only; non-literal types are resolved later by
        // the semantic (IndexStoreDB) backend in `FormatLinter`.
        for moduleName in moduleDirectories {
            let modulePath = (targetsPath as NSString).appendingPathComponent(moduleName)
            let sourcesPath = (modulePath as NSString).appendingPathComponent("Sources")

            guard fileManager.fileExists(atPath: sourcesPath) else {
                if verbose {
                    print("⚠️  No Sources directory in module: \(moduleName)")
                }
                continue
            }

            if verbose {
                print("🔍 Processing module: \(moduleName)")
            }

            let moduleStrings = try extractFromDirectory(
                sourcesPath,
                moduleName: moduleName,
                fileManager: fileManager
            )

            extractedStrings.append(contentsOf: moduleStrings)

            if verbose {
                print("   Found \(moduleStrings.count) strings")
            }
        }

        return extractedStrings
    }

    /// Recursively extract strings from a directory.
    private func extractFromDirectory(
        _ directoryPath: String,
        moduleName: String,
        fileManager: FileManager
    ) throws -> [ExtractedString] {
        var extractedStrings: [ExtractedString] = []

        let enumerator = fileManager.enumerator(atPath: directoryPath)

        while let relativePath = enumerator?.nextObject() as? String {
            let fullPath = (directoryPath as NSString).appendingPathComponent(relativePath)

            guard relativePath.hasSuffix(".swift") else { continue }

            var isDirectory: ObjCBool = false
            guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory),
                  !isDirectory.boolValue else {
                continue
            }

            if verbose {
                print("   📄 \(relativePath)")
            }

            let fileStrings = try extractFromFile(
                fullPath,
                moduleName: moduleName
            )
            extractedStrings.append(contentsOf: fileStrings)
        }

        return extractedStrings
    }

    /// Extract strings from a single Swift file.
    private func extractFromFile(
        _ filePath: String,
        moduleName: String
    ) throws -> [ExtractedString] {
        let sourceCode = try String(contentsOfFile: filePath, encoding: .utf8)
        let sourceFile = Parser.parse(source: sourceCode)
        let converter = SourceLocationConverter(fileName: filePath, tree: sourceFile)

        let visitor = LocalizationVisitor(
            filePath: filePath,
            moduleName: moduleName,
            converter: converter
        )

        visitor.walk(sourceFile)

        return visitor.extractedStrings
    }
}

// MARK: - Visitor

/// SwiftSyntax visitor that finds `.localize()` and `Text.localized()` calls.
private final class LocalizationVisitor: SyntaxVisitor {
    let filePath: String
    let moduleName: String
    let converter: SourceLocationConverter
    private(set) var extractedStrings: [ExtractedString] = []

    init(
        filePath: String,
        moduleName: String,
        converter: SourceLocationConverter
    ) {
        self.filePath = filePath
        self.moduleName = moduleName
        self.converter = converter
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        if let extracted = extractFromStringLocalize(node) {
            extractedStrings.append(extracted)
        } else if let extracted = extractFromTextLocalized(node) {
            extractedStrings.append(extracted)
        }
        return .visitChildren
    }

    /// `"key".localize(default:..., comment:..., with: ...)`
    private func extractFromStringLocalize(_ node: FunctionCallExprSyntax) -> ExtractedString? {
        guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self),
              memberAccess.declName.baseName.text == "localize" else {
            return nil
        }

        guard let keyExpr = memberAccess.base?.as(StringLiteralExprSyntax.self),
              let key = readStringLiteral(keyExpr) else {
            return nil
        }

        return extractStringData(from: node, key: key)
    }

    /// `Text.localized("key", default:..., with: ...)`
    private func extractFromTextLocalized(_ node: FunctionCallExprSyntax) -> ExtractedString? {
        guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self),
              memberAccess.declName.baseName.text == "localized" else {
            return nil
        }

        guard let baseIdentifier = memberAccess.base?.as(DeclReferenceExprSyntax.self),
              baseIdentifier.baseName.text == "Text" else {
            return nil
        }

        guard let firstArg = node.arguments.first,
              firstArg.label == nil,
              let keyExpr = firstArg.expression.as(StringLiteralExprSyntax.self),
              let key = readStringLiteral(keyExpr) else {
            return nil
        }

        return extractStringData(from: node, key: key, skipFirstArgument: true)
    }

    /// Common extraction: parse all interesting arguments + capture source positions.
    private func extractStringData(
        from node: FunctionCallExprSyntax,
        key: String,
        skipFirstArgument: Bool = false
    ) -> ExtractedString? {
        var defaultValue: String = ""
        var comment: String = ""
        var defaultPlural: [String: String]? = nil
        var withArguments: [LintArgument] = []
        var countArgument: LintCountArgument? = nil

        // Walk arguments. Once we see `with:`, every subsequent argument (including
        // any unlabeled trailing variadic arguments) belongs to the with-list, except
        // for `file:` which is always the trailing #fileID slot — we skip it.
        var inWithList = false
        let argList = Array(node.arguments)

        for (index, argument) in argList.enumerated() {
            if skipFirstArgument && index == 0 {
                continue
            }

            let label = argument.label?.text

            if label == "file" {
                inWithList = false
                continue
            }

            if inWithList {
                // Continuation of variadic `with:` list — only unlabeled args belong here.
                if label == nil {
                    withArguments.append(buildLintArgument(label: nil, expression: argument.expression))
                    continue
                } else {
                    inWithList = false
                }
            }

            switch label ?? "" {
            case "default":
                if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
                   let extracted = readStringLiteral(stringLiteral) {
                    defaultValue = extracted
                } else if let dictExpr = argument.expression.as(DictionaryExprSyntax.self) {
                    defaultPlural = parsePluralDictionary(dictExpr)
                }

            case "comment":
                if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
                   let extracted = readStringLiteral(stringLiteral) {
                    comment = extracted
                }

            case "count":
                let location = converter.location(for: argument.expression.position)
                let lookup = lookupLocation(for: argument.expression)
                countArgument = LintCountArgument(
                    text: argument.expression.description.trimmingCharacters(in: .whitespacesAndNewlines),
                    resolvedType: LiteralTypeResolver.resolve(argument.expression),
                    line: location.line,
                    column: location.column,
                    memberLookupLine: lookup?.line,
                    memberLookupColumn: lookup?.column
                )

            case "defaultPlural":
                if let dictExpr = argument.expression.as(DictionaryExprSyntax.self) {
                    defaultPlural = parsePluralDictionary(dictExpr)
                }

            case "with":
                inWithList = true
                withArguments.append(buildLintArgument(label: "with", expression: argument.expression))

            default:
                break
            }
        }

        // Determine type
        let type: TranslationType
        if defaultPlural != nil {
            type = .plural
        } else if defaultValue.contains("%") {
            type = .interpolation
        } else {
            type = .simple
        }

        let location = converter.location(for: node.position)

        return ExtractedString(
            key: key,
            moduleName: moduleName,
            defaultValue: defaultValue,
            comment: comment,
            type: type,
            pluralForms: defaultPlural,
            filePath: filePath,
            lineNumber: location.line,
            column: location.column,
            arguments: withArguments,
            countArgument: countArgument
        )
    }

    private func buildLintArgument(label: String?, expression: ExprSyntax) -> LintArgument {
        let location = converter.location(for: expression.position)
        let lookup = lookupLocation(for: expression)
        return LintArgument(
            label: label,
            text: expression.description.trimmingCharacters(in: .whitespacesAndNewlines),
            resolvedType: LiteralTypeResolver.resolve(expression),
            line: location.line,
            column: location.column,
            memberLookupLine: lookup?.line,
            memberLookupColumn: lookup?.column
        )
    }

    /// Compute the source position (line + UTF-8 column) at which the semantic
    /// resolver should query IndexStoreDB for the type of `expression`.
    ///
    /// For most expressions we want the position of the rightmost identifier
    /// that names the value being passed:
    ///   * `userName`               -> position of `userName`
    ///   * `item.getItemQty()`      -> position of `getItemQty`
    ///   * `viewModel.cart.items`   -> position of `items`
    ///   * `item.getItemQty()!`     -> recurse through force-unwrap
    ///   * Literal `42`             -> `nil` (no symbol to look up)
    ///
    /// The full position (not just the column) matters: a multi-line argument —
    /// a ternary whose branch sits on a later line, or a member chain broken
    /// across lines — has its symbol on a different line than the argument's start.
    private func lookupLocation(for expression: ExprSyntax) -> (line: Int, column: Int)? {
        let unwrapped = unwrapForLookup(expression)

        if let declRef = unwrapped.as(DeclReferenceExprSyntax.self) {
            return position(of: declRef.baseName)
        }
        if let memberAccess = unwrapped.as(MemberAccessExprSyntax.self) {
            return position(of: memberAccess.declName.baseName)
        }
        if let call = unwrapped.as(FunctionCallExprSyntax.self) {
            // For `foo.bar()` look up `bar`; for `Foo()` look up `Foo`.
            return lookupLocation(for: call.calledExpression)
        }
        // Unfolded compound expressions (SwiftParser does not fold operators):
        //   * `a ? b : c`  → resolve the `then` branch; a ternary's type is its
        //                    (shared) branch type.
        //   * `a + b`      → resolve the compiler-resolved operator overload's
        //                    return type via the operator token (e.g. `Int.+ -> Int`).
        // For >1 operator the result type depends on precedence we don't fold, so we
        // decline rather than resolve the wrong slot.
        if let sequence = unwrapped.as(SequenceExprSyntax.self) {
            let elements = Array(sequence.elements)
            if let ternary = elements.lazy.compactMap({ $0.as(UnresolvedTernaryExprSyntax.self) }).first {
                return lookupLocation(for: ternary.thenExpression)
            }
            let operators = elements.compactMap { $0.as(BinaryOperatorExprSyntax.self) }
            if operators.count == 1 {
                return position(of: operators[0].operator)
            }
        }
        return nil
    }

    /// Convert a token's source position to a `(line, column)` pair.
    private func position(of token: TokenSyntax) -> (line: Int, column: Int) {
        let location = converter.location(for: token.positionAfterSkippingLeadingTrivia)
        return (location.line, location.column)
    }

    private func unwrapForLookup(_ expression: ExprSyntax) -> ExprSyntax {
        if let force = expression.as(ForceUnwrapExprSyntax.self) {
            return unwrapForLookup(force.expression)
        }
        if let chain = expression.as(OptionalChainingExprSyntax.self) {
            return unwrapForLookup(chain.expression)
        }
        if let tryExpr = expression.as(TryExprSyntax.self) {
            return unwrapForLookup(tryExpr.expression)
        }
        if let awaitExpr = expression.as(AwaitExprSyntax.self) {
            return unwrapForLookup(awaitExpr.expression)
        }
        // Prefix operators (`-amount`, `!flag`, `~mask`) are type-preserving for the
        // operand, so resolve the inner value's symbol. Without this the whole
        // expression resolved to `.unknown` and its type went unchecked.
        if let prefix = expression.as(PrefixOperatorExprSyntax.self) {
            return unwrapForLookup(prefix.expression)
        }
        if let tuple = expression.as(TupleExprSyntax.self),
           tuple.elements.count == 1,
           let inner = tuple.elements.first {
            return unwrapForLookup(inner.expression)
        }
        return expression
    }

    /// Read the full text of a string literal, joining every `StringSegmentSyntax`
    /// the literal contains.
    ///
    /// SwiftSyntax can split a single string literal into multiple segments around
    /// escape sequences (`\n`, `\t`, `\(...)`, etc.). Reading only the first segment
    /// silently truncates the value at the first escape — which used to make the
    /// extractor miss the trailing `%@` in strings like `"Open this:\n%@"`. We now
    /// concatenate every plain segment; we ignore expression segments because
    /// localized defaults must be compile-time constants for translators.
    private func readStringLiteral(_ literal: StringLiteralExprSyntax) -> String? {
        var result = ""
        for segment in literal.segments {
            guard let stringSegment = segment.as(StringSegmentSyntax.self) else {
                // Interpolation segment encountered — refuse to extract.
                return nil
            }
            result.append(stringSegment.content.text)
        }
        return result
    }

    private func parsePluralDictionary(_ dictExpr: DictionaryExprSyntax) -> [String: String] {
        var result: [String: String] = [:]

        guard case .elements(let elements) = dictExpr.content else {
            return result
        }

        for element in elements {
            if let keyExpr = element.key.as(MemberAccessExprSyntax.self),
               let valueExpr = element.value.as(StringLiteralExprSyntax.self),
               let value = readStringLiteral(valueExpr) {

                let category = keyExpr.declName.baseName.text
                result[category] = value
            }
        }

        return result
    }
}

// MARK: - Errors

public enum ExtractionError: LocalizedError {
    case targetsDirectoryNotFound(path: String)
    case invalidSwiftFile(path: String)

    public var errorDescription: String? {
        switch self {
        case .targetsDirectoryNotFound(let path):
            return "Targets directory not found at: \(path)"
        case .invalidSwiftFile(let path):
            return "Invalid Swift file: \(path)"
        }
    }
}
