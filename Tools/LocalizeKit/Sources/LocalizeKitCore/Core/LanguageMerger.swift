//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// Merges base.json changes into target language files
public final class LanguageMerger {
    public struct Changes {
        public var added: [String] = []
        public var updated: [String] = []
        public var removed: [String] = []
        public var kept: [String] = []

        public init() {}
    }

    public private(set) var changes = Changes()

    public init() {}

    /// Sync target language file with base.json
    public func sync(
        base: BaseTranslationFile,
        target: TargetTranslationFile
    ) -> TargetTranslationFile {
        var updatedModules: [String: [String: TargetTranslationEntry]] = [:]

        // Process each module in base
        for (moduleName, baseStrings) in base.modules {
            let targetStrings = target.modules[moduleName] ?? [:]
            var updatedStrings: [String: TargetTranslationEntry] = [:]

            for (key, baseEntry) in baseStrings {
                if let targetEntry = targetStrings[key] {
                    // EXISTING KEY - check if needs update
                    if baseEntry.version > target.version {
                        // Base key was modified after target was last synced
                        // Replace with English value from base
                        let updated = TargetTranslationEntry(
                            value: baseEntry.value,
                            type: baseEntry.type,
                            comment: baseEntry.comment
                        )
                        updatedStrings[key] = updated
                        changes.updated.append("\(moduleName).\(key)")
                    } else {
                        // Keep existing translation but update comment from base
                        let kept = TargetTranslationEntry(
                            value: targetEntry.value,
                            type: targetEntry.type,
                            comment: baseEntry.comment
                        )
                        updatedStrings[key] = kept
                        changes.kept.append("\(moduleName).\(key)")
                    }
                } else {
                    // NEW KEY - add from base with English value
                    let newEntry = TargetTranslationEntry(
                        value: baseEntry.value,
                        type: baseEntry.type,
                        comment: baseEntry.comment
                    )
                    updatedStrings[key] = newEntry
                    changes.added.append("\(moduleName).\(key)")
                }
            }

            // Check for REMOVED KEYS (in target but not in base)
            for (key, _) in targetStrings {
                if baseStrings[key] == nil {
                    changes.removed.append("\(moduleName).\(key)")
                }
            }

            updatedModules[moduleName] = updatedStrings
        }

        let dateFormatter = ISO8601DateFormatter()
        let generatedAt = dateFormatter.string(from: Date())

        return TargetTranslationFile(
            version: base.version,
            language: target.language,
            generatedAt: generatedAt,
            modules: updatedModules
        )
    }

    /// Create new target language file from base
    public func createFromBase(
        base: BaseTranslationFile,
        language: String
    ) -> TargetTranslationFile {
        var targetModules: [String: [String: TargetTranslationEntry]] = [:]

        // Copy all keys from base with English values
        for (moduleName, baseStrings) in base.modules {
            var targetStrings: [String: TargetTranslationEntry] = [:]

            for (key, baseEntry) in baseStrings {
                let entry = TargetTranslationEntry(
                    value: baseEntry.value,
                    type: baseEntry.type,
                    comment: baseEntry.comment
                )
                targetStrings[key] = entry
                changes.added.append("\(moduleName).\(key)")
            }

            targetModules[moduleName] = targetStrings
        }

        let dateFormatter = ISO8601DateFormatter()
        let generatedAt = dateFormatter.string(from: Date())

        return TargetTranslationFile(
            version: base.version,
            language: language,
            generatedAt: generatedAt,
            modules: targetModules
        )
    }

    /// Load target translation file
    public func loadTargetFile(from path: String) throws -> TargetTranslationFile {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(TargetTranslationFile.self, from: data)
    }

    /// Save target translation file
    public func saveTargetFile(_ file: TargetTranslationFile, to path: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(file)
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    }
}
