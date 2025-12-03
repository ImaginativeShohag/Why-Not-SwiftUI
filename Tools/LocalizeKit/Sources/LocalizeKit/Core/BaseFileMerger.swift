//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// Merges newly extracted strings with existing base.json
final class BaseFileMerger {
    struct Changes {
        var new: [String] = []
        var modified: [String] = []
        var removed: [String] = []
        var commentChanged: [String] = []
    }

    private let ignoreCommentChanges: Bool
    private(set) var changes = Changes()

    init(ignoreCommentChanges: Bool = false) {
        self.ignoreCommentChanges = ignoreCommentChanges
    }

    /// Merge extracted strings into existing base file
    func merge(
        existing: BaseTranslationFile,
        extracted: [ExtractedString],
        newVersion: Int
    ) async throws -> BaseTranslationFile {
        var updatedModules: [String: [String: BaseTranslationEntry]] = [:]

        // Build a lookup map for extracted strings by module and key
        var extractedMap: [String: [String: ExtractedString]] = [:]
        for extracted in extracted {
            var moduleStrings = extractedMap[extracted.moduleName] ?? [:]
            moduleStrings[extracted.key] = extracted
            extractedMap[extracted.moduleName] = moduleStrings
        }

        // Process each module in extracted strings
        for (moduleName, extractedStrings) in extractedMap {
            let existingStrings = existing.modules[moduleName] ?? [:]
            var updatedStrings: [String: BaseTranslationEntry] = [:]

            for (key, extractedString) in extractedStrings {
                if let existingEntry = existingStrings[key] {
                    // EXISTING KEY - compare for changes
                    let updatedEntry = try await processExistingKey(
                        key: key,
                        extracted: extractedString,
                        existing: existingEntry,
                        newVersion: newVersion
                    )
                    updatedStrings[key] = updatedEntry
                } else {
                    // NEW KEY
                    let newEntry = processNewKey(
                        extracted: extractedString,
                        newVersion: newVersion
                    )
                    updatedStrings[key] = newEntry
                    changes.new.append("\(moduleName).\(key)")
                }
            }

            // Check for REMOVED KEYS (in existing but not in extracted)
            for (key, _) in existingStrings {
                if extractedStrings[key] == nil {
                    changes.removed.append("\(moduleName).\(key)")
                }
            }

            updatedModules[moduleName] = updatedStrings
        }

        let dateFormatter = ISO8601DateFormatter()
        let generatedAt = dateFormatter.string(from: Date())

        return BaseTranslationFile(
            version: newVersion,
            language: existing.language,
            generatedAt: generatedAt,
            modules: updatedModules
        )
    }

    // MARK: - Private Helpers

    private func processNewKey(
        extracted: ExtractedString,
        newVersion: Int
    ) -> BaseTranslationEntry {
        let value: TranslationValue
        if let pluralForms = extracted.pluralForms {
            value = .plural(pluralForms)
        } else {
            value = .simple(extracted.defaultValue)
        }

        return BaseTranslationEntry(
            value: value,
            type: extracted.type,
            comment: extracted.comment.isEmpty ? nil : extracted.comment,
            version: newVersion,
            metadata: BaseMetadata(
                addedInVersion: newVersion,
                lastModifiedVersion: nil,
                status: .new
            )
        )
    }

    private func processExistingKey(
        key: String,
        extracted: ExtractedString,
        existing: BaseTranslationEntry,
        newVersion: Int
    ) async throws -> BaseTranslationEntry {
        // Convert extracted to TranslationValue
        let extractedValue: TranslationValue
        if let pluralForms = extracted.pluralForms {
            extractedValue = .plural(pluralForms)
        } else {
            extractedValue = .simple(extracted.defaultValue)
        }

        // Compare values
        let valueChanged = extractedValue.stringValue != existing.value.stringValue

        // Compare comments
        let extractedComment = extracted.comment.isEmpty ? nil : extracted.comment
        let commentChanged = extractedComment != existing.comment

        // Determine if version should be incremented
        var shouldIncrementVersion = false
        var status: TranslationStatus = .unchanged

        if valueChanged {
            // Value changed - always increment version
            shouldIncrementVersion = true
            status = .modified
            changes.modified.append(key)
        } else if commentChanged {
            // Comment changed - ask user or ignore
            if ignoreCommentChanges {
                // Update comment silently without incrementing version
                shouldIncrementVersion = false
                status = existing.metadata?.status ?? .unchanged
            } else {
                // Interactive prompt
                let requiresRetranslation = await promptForCommentChange(
                    key: key,
                    oldComment: existing.comment ?? "",
                    newComment: extractedComment ?? ""
                )

                if requiresRetranslation {
                    shouldIncrementVersion = true
                    status = .modified
                    changes.modified.append(key)
                } else {
                    shouldIncrementVersion = false
                    status = existing.metadata?.status ?? .unchanged
                }
                changes.commentChanged.append(key)
            }
        }

        // Build updated entry
        let updatedVersion = shouldIncrementVersion ? newVersion : existing.version
        let lastModified = shouldIncrementVersion ? newVersion : existing.metadata?.lastModifiedVersion

        return BaseTranslationEntry(
            value: extractedValue,
            type: extracted.type,
            comment: extractedComment,
            version: updatedVersion,
            metadata: BaseMetadata(
                addedInVersion: existing.metadata?.addedInVersion ?? newVersion,
                lastModifiedVersion: lastModified,
                status: status
            )
        )
    }

    private func promptForCommentChange(
        key: String,
        oldComment: String,
        newComment: String
    ) async -> Bool {
        print("\n⚠️  Comment changed for '\(key)':")
        print("   Old: \"\(oldComment)\"")
        print("   New: \"\(newComment)\"")
        print("")
        print("   Does this require re-translation? (y/N): ", terminator: "")
        fflush(stdout)

        guard let response = readLine()?.lowercased() else {
            return false
        }

        return response == "y" || response == "yes"
    }
}
