//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// Generates translation JSON files from extracted strings
public final class TranslationFileGenerator {
    private let version: String
    private let language: String
    private let verbose: Bool

    public init(version: String, language: String, verbose: Bool = false) {
        self.version = version
        self.language = language
        self.verbose = verbose
    }

    /// Generate a TranslationFile from extracted strings
    public func generate(from extractedStrings: [ExtractedString]) -> TranslationFile {
        var moduleDict: [String: [String: TranslationEntry]] = [:]

        // Group strings by module
        for extracted in extractedStrings {
            var moduleStrings = moduleDict[extracted.moduleName] ?? [:]

            // Convert plural forms if present
            let value: TranslationValue
            if let pluralForms = extracted.pluralForms {
                let pluralDict = convertPluralForms(pluralForms)
                value = .plural(pluralDict)
            } else {
                value = .simple(extracted.defaultValue)
            }

            let entry = TranslationEntry(
                value: value,
                type: extracted.type,
                comment: extracted.comment.isEmpty ? nil : extracted.comment,
                metadata: TranslationMetadata(
                    addedInVersion: version,
                    lastModifiedVersion: nil,
                    status: .new,
                    translationStatus: .untranslated,
                    changeReason: nil
                )
            )

            moduleStrings[extracted.key] = entry
            moduleDict[extracted.moduleName] = moduleStrings
        }

        let dateFormatter = ISO8601DateFormatter()
        let generatedAt = dateFormatter.string(from: Date())

        return TranslationFile(
            version: version,
            language: language,
            generatedAt: generatedAt,
            modules: moduleDict
        )
    }

    /// Save translation file to disk
    public func save(_ translationFile: TranslationFile, to outputPath: String) throws {
        let fileManager = FileManager.default

        // Create directory if needed
        let directoryPath = (outputPath as NSString).deletingLastPathComponent
        if !fileManager.fileExists(atPath: directoryPath) {
            try fileManager.createDirectory(
                atPath: directoryPath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }

        // Encode JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(translationFile)

        // Write to file
        try data.write(to: URL(fileURLWithPath: outputPath), options: .atomic)

        if verbose {
            print("✅ Translation file saved to: \(outputPath)")
        }
    }

    /// Generate summary statistics
    public func generateSummary(from translationFile: TranslationFile) -> String {
        var totalStrings = 0
        var simpleStrings = 0
        var pluralStrings = 0
        var interpolationStrings = 0

        for (moduleName, strings) in translationFile.modules {
            totalStrings += strings.count

            for (_, entry) in strings {
                switch entry.type {
                case .simple:
                    simpleStrings += 1
                case .plural:
                    pluralStrings += 1
                case .interpolation:
                    interpolationStrings += 1
                }
            }
        }

        var summary = """

        📊 Translation Summary
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        Version:         \(translationFile.version)
        Language:        \(translationFile.language)
        Generated:       \(translationFile.generatedAt)
        Total Modules:   \(translationFile.modules.count)
        Total Strings:   \(totalStrings)

        String Types:
        • Simple:        \(simpleStrings)
        • Interpolation: \(interpolationStrings)
        • Plural:        \(pluralStrings)

        Modules:
        """

        for (moduleName, strings) in translationFile.modules.sorted(by: { $0.key < $1.key }) {
            summary += "\n• \(moduleName): \(strings.count) strings"
        }

        summary += "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

        return summary
    }

    // MARK: - Private Helpers

    private func convertPluralForms(_ forms: [String: String]) -> [String: String] {
        // Map plural category names to values
        // Input: ["zero": "text", "one": "text"]
        // Output: same format (already correct)
        return forms
    }
}
