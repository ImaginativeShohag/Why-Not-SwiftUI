//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// Merges new extracted strings with existing translations
final class TranslationMerger {
    private let keepRemoved: Bool
    private let verbose: Bool

    init(keepRemoved: Bool, verbose: Bool = false) {
        self.keepRemoved = keepRemoved
        self.verbose = verbose
    }

    /// Merge new strings with existing translations
    func merge(
        newFile: TranslationFile,
        existingFile: TranslationFile
    ) -> TranslationFile {
        var mergedModules: [String: [String: TranslationEntry]] = [:]
        var stats = MergeStats()

        // Get all module names from both files
        let allModules = Set(newFile.modules.keys).union(Set(existingFile.modules.keys))

        for moduleName in allModules {
            let newStrings = newFile.modules[moduleName] ?? [:]
            let existingStrings = existingFile.modules[moduleName] ?? [:]

            var mergedStrings: [String: TranslationEntry] = [:]

            // Process all keys from new file
            for (key, newEntry) in newStrings {
                if let existingEntry = existingStrings[key] {
                    // Key exists in both files
                    if hasValueChanged(old: existingEntry, new: newEntry) {
                        // Value has changed - keep existing translation but mark as needs review
                        mergedStrings[key] = TranslationEntry(
                            value: existingEntry.value,
                            type: newEntry.type,
                            comment: newEntry.comment,
                            metadata: TranslationMetadata(
                                addedInVersion: existingEntry.metadata?.addedInVersion,
                                lastModifiedVersion: newFile.version,
                                status: .modified,
                                translationStatus: .needsReview,
                                changeReason: "Default value changed"
                            )
                        )
                        stats.modified += 1
                    } else {
                        // Value unchanged - keep existing entry
                        mergedStrings[key] = TranslationEntry(
                            value: existingEntry.value,
                            type: newEntry.type,
                            comment: newEntry.comment,
                            metadata: TranslationMetadata(
                                addedInVersion: existingEntry.metadata?.addedInVersion,
                                lastModifiedVersion: existingEntry.metadata?.lastModifiedVersion,
                                status: .unchanged,
                                translationStatus: existingEntry.metadata?.translationStatus ?? .validated,
                                changeReason: nil
                            )
                        )
                        stats.unchanged += 1
                    }
                } else {
                    // New key
                    mergedStrings[key] = TranslationEntry(
                        value: newEntry.value,
                        type: newEntry.type,
                        comment: newEntry.comment,
                        metadata: TranslationMetadata(
                            addedInVersion: newFile.version,
                            lastModifiedVersion: nil,
                            status: .new,
                            translationStatus: .untranslated,
                            changeReason: nil
                        )
                    )
                    stats.new += 1
                }
            }

            // Handle removed keys
            if keepRemoved {
                for (key, existingEntry) in existingStrings {
                    if newStrings[key] == nil {
                        // Key was removed from source code
                        mergedStrings[key] = TranslationEntry(
                            value: existingEntry.value,
                            type: existingEntry.type,
                            comment: existingEntry.comment,
                            metadata: TranslationMetadata(
                                addedInVersion: existingEntry.metadata?.addedInVersion,
                                lastModifiedVersion: newFile.version,
                                status: .removed,
                                translationStatus: existingEntry.metadata?.translationStatus,
                                changeReason: "Removed from source code"
                            )
                        )
                        stats.removed += 1
                    }
                }
            } else {
                // Count removed but don't include them
                for key in existingStrings.keys {
                    if newStrings[key] == nil {
                        stats.removed += 1
                    }
                }
            }

            if !mergedStrings.isEmpty {
                mergedModules[moduleName] = mergedStrings
            }
        }

        if verbose {
            printMergeStats(stats)
        }

        let dateFormatter = ISO8601DateFormatter()
        let generatedAt = dateFormatter.string(from: Date())

        return TranslationFile(
            version: newFile.version,
            language: existingFile.language,
            generatedAt: generatedAt,
            modules: mergedModules
        )
    }

    /// Load translation file from disk
    func loadTranslationFile(from path: String) throws -> TranslationFile {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(TranslationFile.self, from: data)
    }

    /// Save translation file to disk
    func saveTranslationFile(_ file: TranslationFile, to path: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(file)
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    }

    // MARK: - Private Helpers

    private func hasValueChanged(old: TranslationEntry, new: TranslationEntry) -> Bool {
        // Compare the default values (from new file) with old entry structure
        // This is a simplified check - in reality you'd compare the actual default values
        switch (old.value, new.value) {
        case (.simple(let oldStr), .simple(let newStr)):
            return oldStr != newStr
        case (.plural(let oldDict), .plural(let newDict)):
            return oldDict != newDict
        default:
            return true // Type changed
        }
    }

    private func printMergeStats(_ stats: MergeStats) {
        print("""

        📊 Merge Statistics
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        • New:       \(stats.new)
        • Modified:  \(stats.modified)
        • Unchanged: \(stats.unchanged)
        • Removed:   \(stats.removed) \(keepRemoved ? "(kept)" : "(discarded)")
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        """)
    }
}

// MARK: - Supporting Types

private struct MergeStats {
    var new: Int = 0
    var modified: Int = 0
    var unchanged: Int = 0
    var removed: Int = 0
}
