//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation
import LocalizeKitCore

struct LintCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "lint",
        abstract: "Lint .localize / Text.localized call sites for format-specifier and argument-type mismatches",
        discussion: """
        Statically analyses every Swift file under the project's `Targets/` directory,
        finds calls to `.localize(default: …, with: …)` and `Text.localized(_, default: …, with: …)`,
        parses the format specifiers in the default value (or each plural form), and validates that
        the supplied `with:` arguments match in count and type.

        Argument types are resolved authoritatively from Xcode's IndexStoreDB — the same symbol
        index the compiler produces. Literal arguments (`with: 42`, `with: "x"`) are classified
        directly from SwiftSyntax since the index only records symbol references. Arguments whose
        type cannot be resolved are skipped silently to keep false positives low.

        Requires an up-to-date Xcode index: open the project in Xcode and build (⌘B) before linting.

        Reporters:
          • `pretty` (default for terminal use) — grouped, human readable output.
          • `xcode`  (auto-selected when run from an Xcode build phase) — emits
            `file:line:col: error|warning: msg` lines that Xcode parses into the issue navigator.

        Exit codes:
          • 0 if no errors were found (warnings are allowed).
          • 1 if one or more errors were reported, or any issue when `--strict` is set.
        """
    )

    @Option(name: .long, help: "Root directory of the project (default: current directory)")
    var projectPath: String = FileManager.default.currentDirectoryPath

    @Option(
        name: .long,
        help: "Reporter style: 'pretty', 'xcode', or 'auto' (default — Xcode when run as build phase)"
    )
    var reporter: String = "auto"

    @Flag(name: .long, help: "Treat warnings as errors and exit non-zero on any issue")
    var strict: Bool = false

    @Flag(name: .long, help: "Verbose extraction output")
    var verbose: Bool = false

    @Flag(
        inversion: .prefixedNo,
        help: "Emit a warning for every call site whose argument type could not be resolved (custom type/typealias, complex expression, or stale index) so you can verify it by hand. Default: on. Use --no-warn-unverified to silence."
    )
    var warnUnverified: Bool = true

    @Option(
        name: .long,
        help: "Override the path to Xcode's index store. Defaults to auto-discovery from DerivedData."
    )
    var indexStorePath: String?

    func run() async throws {
        let resolvedReporter = resolveReporter()

        // Build the semantic backend before extraction so the linter resolves types
        // against Xcode's actual symbol index. Literal arguments are classified during
        // extraction; everything else is resolved here.
        let semanticResolver = try makeSemanticResolver(reporter: resolvedReporter)

        if resolvedReporter == .pretty {
            print("\n🔎 Linting localization call sites...\n")
            print("Project:  \(projectPath)")
            print("Reporter: \(resolvedReporter.rawValue)")
            print("Strict:   \(strict ? "yes" : "no")")
            print("")
        }

        let extractor = StringExtractor(projectPath: projectPath, verbose: verbose)
        let extracted: [ExtractedString]
        do {
            extracted = try extractor.extract()
        } catch let error as ExtractionError {
            FileHandle.standardError.write(Data("\(error.localizedDescription)\n".utf8))
            throw ExitCode.failure
        }

        if resolvedReporter == .pretty {
            print("📦 Scanned \(extracted.count) localized call site(s)\n")
        }

        let linter = FormatLinter(semanticResolver: semanticResolver, warnUnverified: warnUnverified)
        let issues = linter.lint(extracted)

        emit(issues: issues, reporter: resolvedReporter)

        let errorCount = issues.filter { $0.severity == .error }.count
        let warningCount = issues.filter { $0.severity == .warning }.count

        if !semanticResolver.staleFilePaths.isEmpty {
            warnAboutStaleFiles(semanticResolver.staleFilePaths, reporter: resolvedReporter)
        }

        if resolvedReporter == .pretty {
            printSummary(errorCount: errorCount, warningCount: warningCount, total: extracted.count)
        }

        let shouldFail = errorCount > 0 || (strict && warningCount > 0)
        if shouldFail {
            throw ExitCode.failure
        }
    }

    /// When semantic resolution skips files because the index is older than the
    /// source, surface that to the user — those files fall back to literal-only
    /// type classification, so non-literal arguments go unchecked. Easy fix: rebuild in Xcode.
    private func warnAboutStaleFiles(_ paths: Set<String>, reporter: Reporter) {
        let sorted = paths.sorted()
        let header = "⚠️  Semantic resolution skipped \(sorted.count) file(s) with a stale Xcode index — rebuild the project in Xcode to re-enable semantic types for these files:\n"

        switch reporter {
        case .xcode:
            for path in sorted {
                let line = "\(path):1:1: warning: [LocalizeKit:stale_index] File is newer than Xcode's indexed unit — only literal arguments are type-checked for this file. Rebuild in Xcode to refresh.\n"
                FileHandle.standardError.write(Data(line.utf8))
            }
        case .pretty:
            print(header)
            for path in sorted.prefix(10) {
                print("   • \(relativePath(path))")
            }
            if sorted.count > 10 {
                print("   … and \(sorted.count - 10) more")
            }
            print("")
        }
    }

    // MARK: - Semantic resolver setup

    private func makeSemanticResolver(reporter: Reporter) throws -> SemanticTypeResolver {
        let storePath: String
        if let override = indexStorePath {
            storePath = override
        } else if let discovered = IndexStoreDiscovery.indexStorePath(forProjectAt: projectPath) {
            storePath = discovered
        } else {
            let message = """
            ❌ Could not locate Xcode's index store for project at '\(projectPath)'.
               LocalizeKit needs the index store to perform semantic type resolution.

               Fix:
                 1. Open the project in Xcode and run a build (⌘B).
                 2. Re-run `localizekit lint`.

               Or override the index path explicitly:
                 localizekit lint --index-store-path /path/to/DerivedData/<id>/Index.noindex/DataStore

            """
            FileHandle.standardError.write(Data(message.utf8))
            throw ExitCode.failure
        }

        guard let libraryPath = IndexStoreDiscovery.indexStoreLibraryPath() else {
            FileHandle.standardError.write(Data("""
                ❌ Could not locate libIndexStore.dylib in the active Xcode toolchain.
                   Run `xcode-select -s /Applications/Xcode.app/Contents/Developer` and try again.

                """.utf8))
            throw ExitCode.failure
        }

        let dbPath = try IndexStoreDiscovery.databasePath(forProjectAt: projectPath)

        if reporter == .pretty {
            print("🧠 Semantic index: \(storePath)")
        }

        do {
            return try SemanticTypeResolver(
                storePath: storePath,
                databasePath: dbPath,
                libraryPath: libraryPath
            )
        } catch {
            FileHandle.standardError.write(Data("""
                ❌ Failed to open Xcode index store at:
                     \(storePath)
                   Error: \(error)

                   Try rebuilding the project in Xcode (⌘B), then re-run `localizekit lint`.

                """.utf8))
            throw ExitCode.failure
        }
    }

    // MARK: - Reporter

    private enum Reporter: String {
        case pretty
        case xcode
    }

    private func resolveReporter() -> Reporter {
        switch reporter.lowercased() {
        case "pretty":
            return .pretty
        case "xcode":
            return .xcode
        case "auto":
            // Xcode build phases always set XCODE_PRODUCT_BUILD_VERSION (and many other vars).
            let env = ProcessInfo.processInfo.environment
            if env["XCODE_PRODUCT_BUILD_VERSION"] != nil
                || env["XCODE_VERSION_ACTUAL"] != nil
                || env["BUILT_PRODUCTS_DIR"] != nil {
                return .xcode
            }
            return .pretty
        default:
            return .pretty
        }
    }

    private func emit(issues: [LintIssue], reporter: Reporter) {
        switch reporter {
        case .xcode:
            emitXcode(issues: issues)
        case .pretty:
            emitPretty(issues: issues)
        }
    }

    /// Emit issues in Xcode-parsable format on stderr so they show up in the build log
    /// regardless of which stream Xcode is capturing.
    private func emitXcode(issues: [LintIssue]) {
        for issue in issues {
            // Apply --strict promotion at emission time so Xcode sees the right severity.
            let severity: LintSeverity = (strict && issue.severity == .warning) ? .error : issue.severity
            let line = "\(issue.filePath):\(issue.line):\(issue.column): \(severity.rawValue): [LocalizeKit:\(issue.ruleID)] \(issue.message)\n"
            FileHandle.standardError.write(Data(line.utf8))
        }
    }

    private func emitPretty(issues: [LintIssue]) {
        guard !issues.isEmpty else {
            print("✅ No issues found in localized call sites.\n")
            return
        }

        let grouped = Dictionary(grouping: issues, by: { $0.filePath })
        let sortedFiles = grouped.keys.sorted()

        for file in sortedFiles {
            let fileIssues = (grouped[file] ?? []).sorted {
                $0.line == $1.line ? $0.column < $1.column : $0.line < $1.line
            }
            print("📄 \(relativePath(file))")
            for issue in fileIssues {
                let symbol = issue.severity == .error ? "❌" : "⚠️ "
                print("   \(symbol) \(issue.line):\(issue.column)  [\(issue.ruleID)] \(issue.message)")
            }
            print("")
        }
    }

    private func printSummary(errorCount: Int, warningCount: Int, total: Int) {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("Summary")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("Call sites: \(total)")
        print("Errors:     \(errorCount)")
        print("Warnings:   \(warningCount)")
        print("")

        if errorCount == 0 && warningCount == 0 {
            print("✅ All localization call sites passed lint.\n")
        } else if errorCount == 0 {
            print("⚠️  Lint completed with warnings.\n")
        } else {
            print("❌ Lint failed.\n")
        }
    }

    private func relativePath(_ absolute: String) -> String {
        let prefix = projectPath.hasSuffix("/") ? projectPath : projectPath + "/"
        if absolute.hasPrefix(prefix) {
            return String(absolute.dropFirst(prefix.count))
        }
        return absolute
    }
}
