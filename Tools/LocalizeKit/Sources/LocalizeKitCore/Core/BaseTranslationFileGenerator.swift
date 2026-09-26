//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// Generates base.json files from extracted strings
public final class BaseTranslationFileGenerator {
    private let version: Int
    private let verbose: Bool

    public init(version: Int, verbose: Bool = false) {
        self.version = version
        self.verbose = verbose
    }

    /// Generate a BaseTranslationFile from extracted strings
    public func generate(from extractedStrings: [ExtractedString]) -> BaseTranslationFile {
        var moduleDict: [String: [String: BaseTranslationEntry]] = [:]

        // Group strings by module
        for extracted in extractedStrings {
            var moduleStrings = moduleDict[extracted.moduleName] ?? [:]

            // Convert plural forms if present
            let value: TranslationValue
            if let pluralForms = extracted.pluralForms {
                value = .plural(pluralForms)
            } else {
                value = .simple(extracted.defaultValue)
            }

            let entry = BaseTranslationEntry(
                value: value,
                type: extracted.type,
                comment: extracted.comment.isEmpty ? nil : extracted.comment,
                version: version,
                metadata: BaseMetadata(
                    addedInVersion: version,
                    lastModifiedVersion: nil,
                    status: .new
                )
            )

            moduleStrings[extracted.key] = entry
            moduleDict[extracted.moduleName] = moduleStrings
        }

        let dateFormatter = ISO8601DateFormatter()
        let generatedAt = dateFormatter.string(from: Date())

        return BaseTranslationFile(
            version: version,
            language: "en",
            generatedAt: generatedAt,
            modules: moduleDict
        )
    }

    /// Save base translation file to disk
    public func save(_ translationFile: BaseTranslationFile, to outputPath: String) throws {
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
            print("✅ Base translation file saved to: \(outputPath)")
        }
    }

    /// Load existing base file
    public func load(from path: String) throws -> BaseTranslationFile {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(BaseTranslationFile.self, from: data)
    }

    /// Generate summary statistics
    public func generateSummary(from translationFile: BaseTranslationFile) -> String {
        var totalStrings = 0
        var simpleStrings = 0
        var pluralStrings = 0
        var interpolationStrings = 0

        for (_, strings) in translationFile.modules {
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
}
