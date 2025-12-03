//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// Generates diff between two translation file versions
final class DiffGenerator {
    private let verbose: Bool

    init(verbose: Bool = false) {
        self.verbose = verbose
    }

    /// Generate diff between two translation files
    func generateDiff(
        oldFile: TranslationFile,
        newFile: TranslationFile
    ) -> DiffFile {
        var changesByModule: [String: LegacyModuleChanges] = [:]
        var summary = DiffSummary(new: 0, modified: 0, removed: 0, unchanged: 0)

        // Get all modules from both files
        let allModules = Set(oldFile.modules.keys).union(Set(newFile.modules.keys))

        for moduleName in allModules {
            let oldStrings = oldFile.modules[moduleName] ?? [:]
            let newStrings = newFile.modules[moduleName] ?? [:]

            var newEntries: [String: TranslationEntry] = [:]
            var modifiedEntries: [String: ModifiedEntry] = [:]
            var removedEntries: [String: TranslationEntry] = [:]

            // Find new and modified entries
            for (key, newEntry) in newStrings {
                if let oldEntry = oldStrings[key] {
                    // Check if modified
                    if !areEntriesEqual(old: oldEntry, new: newEntry) {
                        modifiedEntries[key] = ModifiedEntry(
                            oldValue: oldEntry.value,
                            newValue: newEntry.value,
                            type: newEntry.type,
                            comment: newEntry.comment
                        )
                        summary.modified += 1
                    } else {
                        summary.unchanged += 1
                    }
                } else {
                    // New entry
                    newEntries[key] = newEntry
                    summary.new += 1
                }
            }

            // Find removed entries
            for (key, oldEntry) in oldStrings {
                if newStrings[key] == nil {
                    removedEntries[key] = oldEntry
                    summary.removed += 1
                }
            }

            // Only add module if there are changes
            if !newEntries.isEmpty || !modifiedEntries.isEmpty || !removedEntries.isEmpty {
                changesByModule[moduleName] = LegacyModuleChanges(
                    new: newEntries,
                    modified: modifiedEntries,
                    removed: removedEntries
                )
            }
        }

        let dateFormatter = ISO8601DateFormatter()
        let generatedAt = dateFormatter.string(from: Date())

        return DiffFile(
            version: newFile.version,
            previousVersion: oldFile.version,
            generatedAt: generatedAt,
            summary: summary,
            changesByModule: changesByModule
        )
    }

    /// Save diff file as JSON
    func saveDiffJSON(_ diffFile: DiffFile, to path: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(diffFile)
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)

        if verbose {
            print("✅ Diff saved as JSON to: \(path)")
        }
    }

    /// Save diff file as Markdown
    func saveDiffMarkdown(_ diffFile: DiffFile, to path: String) throws {
        var markdown = generateMarkdown(from: diffFile)
        try markdown.write(toFile: path, atomically: true, encoding: .utf8)

        if verbose {
            print("✅ Diff saved as Markdown to: \(path)")
        }
    }

    /// Load translation file from disk
    func loadTranslationFile(from path: String) throws -> TranslationFile {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(TranslationFile.self, from: data)
    }

    /// Print diff summary
    func printSummary(_ diffFile: DiffFile) {
        print("""

        📊 Diff Summary
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        From Version: \(diffFile.previousVersion)
        To Version:   \(diffFile.version)
        Generated:    \(diffFile.generatedAt)

        Changes:
        • New:        \(diffFile.summary.new)
        • Modified:   \(diffFile.summary.modified)
        • Removed:    \(diffFile.summary.removed)
        • Unchanged:  \(diffFile.summary.unchanged)

        Affected Modules: \(diffFile.changesByModule.count)
        """)

        for (moduleName, changes) in diffFile.changesByModule.sorted(by: { $0.key < $1.key }) {
            let totalChanges = changes.new.count + changes.modified.count + changes.removed.count
            print("• \(moduleName): \(totalChanges) changes")
        }

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    }

    // MARK: - Private Helpers

    private func areEntriesEqual(old: TranslationEntry, new: TranslationEntry) -> Bool {
        // Compare values
        switch (old.value, new.value) {
        case (.simple(let oldStr), .simple(let newStr)):
            if oldStr != newStr { return false }
        case (.plural(let oldDict), .plural(let newDict)):
            if oldDict != newDict { return false }
        default:
            return false // Type changed
        }

        // Compare type
        if old.type != new.type { return false }

        // Compare comment (optional)
        if old.comment != new.comment { return false }

        return true
    }

    private func generateMarkdown(from diffFile: DiffFile) -> String {
        var markdown = """
        # Translation Changes

        **From Version:** \(diffFile.previousVersion)
        **To Version:** \(diffFile.version)
        **Generated:** \(diffFile.generatedAt)

        ## Summary

        | Status    | Count |
        |-----------|------:|
        | New       | \(diffFile.summary.new) |
        | Modified  | \(diffFile.summary.modified) |
        | Removed   | \(diffFile.summary.removed) |
        | Unchanged | \(diffFile.summary.unchanged) |

        ---


        """

        for (moduleName, changes) in diffFile.changesByModule.sorted(by: { $0.key < $1.key }) {
            markdown += "\n## Module: `\(moduleName)`\n\n"

            // New entries
            if !changes.new.isEmpty {
                markdown += "### ✨ New Strings (\(changes.new.count))\n\n"
                for (key, entry) in changes.new.sorted(by: { $0.key < $1.key }) {
                    markdown += "- **`\(key)`**\n"
                    if let comment = entry.comment {
                        markdown += "  - *\(comment)*\n"
                    }
                    markdown += "  - Value: `\(formatValue(entry.value))`\n\n"
                }
            }

            // Modified entries
            if !changes.modified.isEmpty {
                markdown += "### 🔄 Modified Strings (\(changes.modified.count))\n\n"
                for (key, entry) in changes.modified.sorted(by: { $0.key < $1.key }) {
                    markdown += "- **`\(key)`**\n"
                    if let comment = entry.comment {
                        markdown += "  - *\(comment)*\n"
                    }
                    markdown += "  - Old: `\(formatValue(entry.oldValue))`\n"
                    markdown += "  - New: `\(formatValue(entry.newValue))`\n\n"
                }
            }

            // Removed entries
            if !changes.removed.isEmpty {
                markdown += "### ❌ Removed Strings (\(changes.removed.count))\n\n"
                for (key, entry) in changes.removed.sorted(by: { $0.key < $1.key }) {
                    markdown += "- **`\(key)`**\n"
                    if let comment = entry.comment {
                        markdown += "  - *\(comment)*\n"
                    }
                    markdown += "  - Value: `\(formatValue(entry.value))`\n\n"
                }
            }

            markdown += "---\n\n"
        }

        return markdown
    }

    private func formatValue(_ value: TranslationValue) -> String {
        switch value {
        case .simple(let text):
            return text
        case .plural(let dict):
            return dict.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        }
    }
}
