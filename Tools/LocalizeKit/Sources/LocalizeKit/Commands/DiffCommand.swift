//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation
import LocalizeKitCore

struct DiffCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "diff",
        abstract: "Show translation differences between target languages and base.json"
    )

    @Option(name: .long, help: "Target language code(s) to compare with base (repeatable)")
    var language: [String] = []

    @Flag(name: .long, help: "Compare all languages with base")
    var all: Bool = false

    @Option(name: .long, help: "Root directory of the project (default: current directory)")
    var projectPath: String = FileManager.default.currentDirectoryPath

    @Flag(name: .long, help: "Verbose output")
    var verbose: Bool = false

    func run() async throws {
        let translationsDir = (projectPath as NSString).appendingPathComponent("Translations")
        let basePath = (translationsDir as NSString).appendingPathComponent("base.json")

        print("\n📊 Comparing translations with base.json...\n")

        do {
            // Load base.json
            guard FileManager.default.fileExists(atPath: basePath) else {
                print("❌ base.json not found at: \(basePath)")
                print("💡 Run 'extract' command first to generate base.json")
                throw ExitCode.failure
            }

            let baseFile = try loadBaseFile(from: basePath)

            // Determine target languages
            let targetLanguages = try determineTargetLanguages(translationsDir: translationsDir)

            guard !targetLanguages.isEmpty else {
                print("❌ No target languages specified.")
                print("💡 Use --language ar or --all")
                throw ExitCode.failure
            }

            // Show diff for each language
            for lang in targetLanguages {
                try await showDiff(
                    language: lang,
                    baseFile: baseFile,
                    translationsDir: translationsDir
                )
            }

        } catch let error as DecodingError {
            print("❌ Failed to parse translation file:")
            print("   \(error.localizedDescription)")
            throw ExitCode.failure
        } catch {
            print("❌ Diff generation failed: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }

    // MARK: - Private Methods

    private func determineTargetLanguages(translationsDir: String) throws -> [String] {
        if all {
            return try findAllLanguageFiles(in: translationsDir)
        } else {
            return language
        }
    }

    private func findAllLanguageFiles(in directory: String) throws -> [String] {
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(atPath: directory)

        return files
            .filter { $0.hasSuffix(".json") && $0 != "base.json" }
            .map { $0.replacingOccurrences(of: ".json", with: "") }
            .sorted()
    }

    private func showDiff(
        language: String,
        baseFile: BaseTranslationFile,
        translationsDir: String
    ) async throws {
        let targetPath = (translationsDir as NSString).appendingPathComponent("\(language).json")

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("Diff: \(language).json ↔ base.json")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")

        guard FileManager.default.fileExists(atPath: targetPath) else {
            print("❌ File not found: \(language).json")
            print("💡 Run 'merge --language \(language)' to create it")
            print("")
            return
        }

        let targetFile = try loadTargetFile(from: targetPath)

        var newKeys: [(module: String, key: String, value: String)] = []
        var modifiedKeys: [(module: String, key: String, baseValue: String, targetValue: String, version: Int)] = []
        var removedKeys: [(module: String, key: String, value: String)] = []
        var upToDateCount = 0

        // Compare base with target
        for (moduleName, baseStrings) in baseFile.modules {
            let targetStrings = targetFile.modules[moduleName] ?? [:]

            for (key, baseEntry) in baseStrings {
                if let targetEntry = targetStrings[key] {
                    // Key exists - check if outdated
                    if baseEntry.version > targetFile.version {
                        modifiedKeys.append((
                            module: moduleName,
                            key: key,
                            baseValue: baseEntry.value.stringValue,
                            targetValue: targetEntry.value.stringValue,
                            version: baseEntry.version
                        ))
                    } else {
                        upToDateCount += 1
                    }
                } else {
                    // Key missing in target
                    newKeys.append((
                        module: moduleName,
                        key: key,
                        value: baseEntry.value.stringValue
                    ))
                }
            }

            // Check for removed keys
            for (key, targetEntry) in targetStrings {
                if baseStrings[key] == nil {
                    removedKeys.append((
                        module: moduleName,
                        key: key,
                        value: targetEntry.value.stringValue
                    ))
                }
            }
        }

        // Print summary
        print("Summary:")
        print("  🆕 New keys:      \(newKeys.count)")
        print("  🔄 Modified:      \(modifiedKeys.count)")
        print("  ❌ Removed:       \(removedKeys.count)")
        print("  ✅ Up-to-date:    \(upToDateCount)")
        print("")

        if targetFile.version < baseFile.version {
            print("⚠️  Target file version (\(targetFile.version)) is behind base version (\(baseFile.version))")
            print("")
        }

        // Print details
        if !newKeys.isEmpty {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("")
            print("🆕 NEW KEYS (not in \(language).json):")
            print("")

            var currentModule = ""
            for item in newKeys {
                if item.module != currentModule {
                    currentModule = item.module
                    print("  Module: \(currentModule)")
                }
                print("    • \(item.key)")
                if verbose {
                    print("      Base: \"\(truncate(item.value, maxLength: 60))\"")
                }
            }
            print("")
        }

        if !modifiedKeys.isEmpty {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("")
            print("🔄 MODIFIED (base changed, needs re-translation):")
            print("")

            var currentModule = ""
            for item in modifiedKeys {
                if item.module != currentModule {
                    currentModule = item.module
                    print("  Module: \(currentModule)")
                }
                print("    • \(item.key)")
                print("      Base v\(item.version): \"\(truncate(item.baseValue, maxLength: 50))\"")
                print("      \(language):        \"\(truncate(item.targetValue, maxLength: 50))\" ⚠️ OUTDATED")
                print("")
            }
        }

        if !removedKeys.isEmpty {
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("")
            print("❌ REMOVED (in \(language).json but not in base):")
            print("")

            var currentModule = ""
            for item in removedKeys {
                if item.module != currentModule {
                    currentModule = item.module
                    print("  Module: \(currentModule)")
                }
                print("    • \(item.key)")
                if verbose {
                    print("      \(language): \"\(truncate(item.value, maxLength: 60))\"")
                }
            }
            print("")
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("")

        if !newKeys.isEmpty || !modifiedKeys.isEmpty || !removedKeys.isEmpty {
            print("✅ Recommendation:")
            print("   Run: merge --language \(language)")
            print("   This will add \(newKeys.count) new keys and update \(modifiedKeys.count) modified keys.")
        } else {
            print("✅ \(language).json is fully synchronized with base.json")
        }

        print("")
        print("")
    }

    // MARK: - Helper Methods

    private func loadBaseFile(from path: String) throws -> BaseTranslationFile {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(BaseTranslationFile.self, from: data)
    }

    private func loadTargetFile(from path: String) throws -> TargetTranslationFile {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(TargetTranslationFile.self, from: data)
    }

    private func truncate(_ str: String, maxLength: Int) -> String {
        if str.count <= maxLength {
            return str
        }
        let truncated = str.prefix(maxLength)
        return String(truncated) + "..."
    }
}
