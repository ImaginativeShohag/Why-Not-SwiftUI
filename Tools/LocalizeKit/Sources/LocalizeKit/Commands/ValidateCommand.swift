//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation
import LocalizeKitCore

struct ValidateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate translation files against base.json"
    )

    @Option(name: .long, help: "Target language code(s) to validate (repeatable)")
    var language: [String] = []

    @Flag(name: .long, help: "Validate all language files including base")
    var all: Bool = false

    @Option(name: .long, help: "Root directory of the project (default: current directory)")
    var projectPath: String = FileManager.default.currentDirectoryPath

    @Flag(name: .long, help: "Check for missing translations")
    var checkMissing: Bool = true

    @Flag(name: .long, help: "Check for format string mismatches")
    var checkFormat: Bool = true

    @Flag(name: .long, help: "Check for plural forms")
    var checkPlurals: Bool = true

    @Flag(name: .long, help: "Verbose output")
    var verbose: Bool = false

    func run() async throws {
        let translationsDir = (projectPath as NSString).appendingPathComponent("Translations")
        let basePath = (translationsDir as NSString).appendingPathComponent("base.json")

        print("\n✅ Validating translation files...\n")
        print("Project:       \(projectPath)")
        print("Translations:  \(translationsDir)")
        print("")

        do {
            // Load base.json (always needed)
            guard FileManager.default.fileExists(atPath: basePath) else {
                print("❌ base.json not found at: \(basePath)")
                print("💡 Run 'extract' command first to generate base.json")
                throw ExitCode.failure
            }

            let baseFile = try loadBaseFile(from: basePath)

            // Determine target languages
            var targetLanguages = language
            if all {
                // Include base.json and all target files
                let allFiles = try findAllLanguageFiles(in: translationsDir)
                targetLanguages = ["base"] + allFiles
            }

            guard !targetLanguages.isEmpty else {
                print("❌ No languages specified.")
                print("💡 Use --language ar or --all")
                throw ExitCode.failure
            }

            print("📋 Validating: \(targetLanguages.joined(separator: ", "))\n")

            var allValid = true

            // Validate each language
            for lang in targetLanguages {
                let isValid = try await validateLanguage(
                    language: lang,
                    baseFile: baseFile,
                    translationsDir: translationsDir
                )
                if !isValid {
                    allValid = false
                }
            }

            if allValid {
                print("\n✅ All validations passed!\n")
            } else {
                print("\n❌ Some validations failed.\n")
                throw ExitCode.failure
            }

        } catch let error as DecodingError {
            print("❌ Failed to parse translation file:")
            print("   \(error.localizedDescription)")
            throw ExitCode.failure
        } catch {
            print("❌ Validation error: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }

    // MARK: - Private Methods

    private func findAllLanguageFiles(in directory: String) throws -> [String] {
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(atPath: directory)

        return files
            .filter { $0.hasSuffix(".json") && $0 != "base.json" }
            .map { $0.replacingOccurrences(of: ".json", with: "") }
            .sorted()
    }

    private func validateLanguage(
        language: String,
        baseFile: BaseTranslationFile,
        translationsDir: String
    ) async throws -> Bool {
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🌐 Language: \(language)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        if language == "base" {
            // Validate base.json structure
            return validateBaseFile(baseFile)
        } else {
            // Validate target language file
            let targetPath = (translationsDir as NSString).appendingPathComponent("\(language).json")

            guard FileManager.default.fileExists(atPath: targetPath) else {
                print("❌ File not found: \(language).json")
                print("")
                return false
            }

            let targetFile = try loadTargetFile(from: targetPath)
            return validateTargetFile(targetFile, against: baseFile)
        }
    }

    private func validateBaseFile(_ baseFile: BaseTranslationFile) -> Bool {
        var errors: [String] = []
        var warnings: [String] = []
        var totalKeys = 0

        // Check structure
        if baseFile.modules.isEmpty {
            errors.append("No modules found")
        }

        // Check each module
        for (moduleName, strings) in baseFile.modules {
            totalKeys += strings.count

            for (key, entry) in strings {
                // Check version consistency
                if entry.version > baseFile.version {
                    errors.append("\(moduleName).\(key): key version (\(entry.version)) > file version (\(baseFile.version))")
                }

                // Check format specifiers
                if checkFormat && entry.type == .interpolation {
                    if !hasFormatSpecifiers(entry.value) {
                        warnings.append("\(moduleName).\(key): marked as interpolation but no format specifiers found")
                    }
                }

                // Check plural forms
                if checkPlurals && entry.type == .plural {
                    if case .plural(let dict) = entry.value {
                        if dict.isEmpty {
                            errors.append("\(moduleName).\(key): marked as plural but no plural forms defined")
                        }
                    }
                }
            }
        }

        // Print results
        print("📊 Statistics:")
        print("   Modules:     \(baseFile.modules.count)")
        print("   Total keys:  \(totalKeys)")
        print("   Version:     \(baseFile.version)")
        print("")

        if !errors.isEmpty {
            print("❌ Errors (\(errors.count)):")
            for error in errors {
                print("   • \(error)")
            }
            print("")
        }

        if !warnings.isEmpty {
            print("⚠️  Warnings (\(warnings.count)):")
            for warning in warnings {
                print("   • \(warning)")
            }
            print("")
        }

        if errors.isEmpty {
            print("✅ base.json is valid")
        } else {
            print("❌ base.json has errors")
        }
        print("")

        return errors.isEmpty
    }

    private func validateTargetFile(_ targetFile: TargetTranslationFile, against baseFile: BaseTranslationFile) -> Bool {
        var errors: [String] = []
        var warnings: [String] = []
        var missingKeys: [String] = []
        var extraKeys: [String] = []
        var untranslatedKeys: [String] = []
        var formatMismatches: [String] = []
        var totalKeys = 0

        // Check each module in base
        for (moduleName, baseStrings) in baseFile.modules {
            let targetStrings = targetFile.modules[moduleName] ?? [:]

            for (key, baseEntry) in baseStrings {
                totalKeys += 1

                if let targetEntry = targetStrings[key] {
                    // Key exists - check for issues

                    // Check if untranslated (same as English)
                    if checkMissing && targetEntry.value.stringValue == baseEntry.value.stringValue {
                        untranslatedKeys.append("\(moduleName).\(key)")
                    }

                    // Check format specifiers match
                    if checkFormat && baseEntry.type == .interpolation {
                        let baseSpecifiers = extractFormatSpecifiers(from: baseEntry.value)
                        let targetSpecifiers = extractFormatSpecifiers(from: targetEntry.value)

                        if baseSpecifiers != targetSpecifiers {
                            formatMismatches.append("\(moduleName).\(key): format mismatch (base: \(baseSpecifiers), target: \(targetSpecifiers))")
                        }
                    }

                    // Check plural forms
                    if checkPlurals && baseEntry.type == .plural {
                        if case .plural(let baseDict) = baseEntry.value,
                           case .plural(let targetDict) = targetEntry.value {
                            let baseKeys = Set(baseDict.keys)
                            let targetKeys = Set(targetDict.keys)

                            if baseKeys != targetKeys {
                                warnings.append("\(moduleName).\(key): plural forms mismatch")
                            }
                        }
                    }
                } else {
                    // Key missing in target
                    if checkMissing {
                        missingKeys.append("\(moduleName).\(key)")
                    }
                }
            }

            // Check for extra keys in target
            for (key, _) in targetStrings {
                if baseStrings[key] == nil {
                    extraKeys.append("\(moduleName).\(key)")
                }
            }
        }

        // Print results
        print("📊 Statistics:")
        print("   File version:    \(targetFile.version) (base: \(baseFile.version))")
        print("   Total keys:      \(totalKeys)")
        print("   Missing:         \(missingKeys.count)")
        print("   Extra:           \(extraKeys.count)")
        print("   Untranslated:    \(untranslatedKeys.count)")
        print("   Format issues:   \(formatMismatches.count)")
        print("")

        if targetFile.version < baseFile.version {
            warnings.append("Target file version (\(targetFile.version)) is behind base version (\(baseFile.version)). Run 'merge' command.")
        }

        if !missingKeys.isEmpty {
            print("❌ Missing keys (\(missingKeys.count)):")
            for key in missingKeys.prefix(10) {
                print("   • \(key)")
            }
            if missingKeys.count > 10 {
                print("   ... and \(missingKeys.count - 10) more")
            }
            print("")
        }

        if !extraKeys.isEmpty {
            print("⚠️  Extra keys (\(extraKeys.count)):")
            for key in extraKeys.prefix(10) {
                print("   • \(key)")
            }
            if extraKeys.count > 10 {
                print("   ... and \(extraKeys.count - 10) more")
            }
            print("")
        }

        if !untranslatedKeys.isEmpty {
            print("⚠️  Untranslated (still in English) (\(untranslatedKeys.count)):")
            for key in untranslatedKeys.prefix(10) {
                print("   • \(key)")
            }
            if untranslatedKeys.count > 10 {
                print("   ... and \(untranslatedKeys.count - 10) more")
            }
            print("")
        }

        if !formatMismatches.isEmpty {
            print("❌ Format specifier mismatches (\(formatMismatches.count)):")
            for mismatch in formatMismatches {
                print("   • \(mismatch)")
            }
            print("")
        }

        if !warnings.isEmpty && verbose {
            print("⚠️  Warnings (\(warnings.count)):")
            for warning in warnings {
                print("   • \(warning)")
            }
            print("")
        }

        let hasErrors = !missingKeys.isEmpty || !formatMismatches.isEmpty
        if hasErrors {
            print("❌ \(targetFile.language).json has errors")
        } else {
            print("✅ \(targetFile.language).json is valid")
        }
        print("")

        return !hasErrors
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

    private func hasFormatSpecifiers(_ value: TranslationValue) -> Bool {
        let str = value.stringValue
        return str.contains("%@") || str.contains("%d") || str.contains("%f") || str.contains("%s")
    }

    private func extractFormatSpecifiers(from value: TranslationValue) -> [String] {
        let str = value.stringValue
        let pattern = "%[@dfs]"

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }

        let matches = regex.matches(in: str, range: NSRange(str.startIndex..., in: str))
        return matches.compactMap { match in
            guard let range = Range(match.range, in: str) else { return nil }
            return String(str[range])
        }
    }
}
