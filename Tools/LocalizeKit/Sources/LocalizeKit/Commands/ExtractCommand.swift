//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation
import LocalizeKitCore

struct ExtractCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "extract",
        abstract: "Extract localization strings from Swift files and update base.json"
    )

    @Option(name: .long, help: "Root directory of the project (default: current directory)")
    var projectPath: String = FileManager.default.currentDirectoryPath

    @Flag(name: .long, help: "Skip interactive prompts for comment changes")
    var ignoreCommentChanges: Bool = false

    @Flag(name: .long, help: "Verbose output")
    var verbose: Bool = false

    func run() async throws {
        let translationsDir = (projectPath as NSString).appendingPathComponent("Translations")
        let basePath = (translationsDir as NSString).appendingPathComponent("base.json")

        print("\n🔍 Extracting localization strings...\n")
        print("Project:       \(projectPath)")
        print("Translations:  \(translationsDir)")
        print("")

        do {
            // Extract strings from code
            let extractor = StringExtractor(projectPath: projectPath, verbose: verbose)
            let extractedStrings = try extractor.extract()

            guard !extractedStrings.isEmpty else {
                print("⚠️  No localization strings found in the project.")
                print("💡 Make sure you're using .localize() or Text.localized() methods.")
                throw ExitCode.failure
            }

            // Check if base.json exists
            if FileManager.default.fileExists(atPath: basePath) {
                try await performIncrementalExtraction(
                    basePath: basePath,
                    extractedStrings: extractedStrings
                )
            } else {
                try await performInitialExtraction(
                    outputPath: basePath,
                    extractedStrings: extractedStrings
                )
            }

        } catch let error as ExtractionError {
            print("❌ Extraction failed: \(error.localizedDescription)")
            throw ExitCode.failure
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }

    // MARK: - Initial Extraction

    private func performInitialExtraction(
        outputPath: String,
        extractedStrings: [ExtractedString]
    ) async throws {
        print("📝 Creating base.json with version 1\n")

        let generator = BaseTranslationFileGenerator(version: 1, verbose: verbose)
        let baseFile = generator.generate(from: extractedStrings)

        try generator.save(baseFile, to: outputPath)

        print(generator.generateSummary(from: baseFile))

        print("✅ Created base.json successfully!")
        print("📄 Output file: \(outputPath)\n")
    }

    // MARK: - Incremental Extraction

    private func performIncrementalExtraction(
        basePath: String,
        extractedStrings: [ExtractedString]
    ) async throws {
        print("🔄 Updating existing base.json\n")

        let generator = BaseTranslationFileGenerator(version: 1, verbose: verbose)

        // Load existing base.json
        guard let existingBase = try? generator.load(from: basePath) else {
            print("❌ Failed to load existing base.json")
            throw ExitCode.failure
        }

        let newVersion = existingBase.version + 1
        print("📌 Incrementing version: \(existingBase.version) → \(newVersion)\n")

        // Merge changes
        let merger = BaseFileMerger(ignoreCommentChanges: ignoreCommentChanges)
        let updatedBase = try await merger.merge(
            existing: existingBase,
            extracted: extractedStrings,
            newVersion: newVersion
        )

        // Save updated file
        try generator.save(updatedBase, to: basePath)

        // Print summary
        print(generator.generateSummary(from: updatedBase))

        printChangeSummary(merger.changes)

        print("✅ Updated base.json to version \(newVersion)!")
        print("📄 Output file: \(basePath)\n")
    }

    // MARK: - Summary Printing

    private func printChangeSummary(_ changes: BaseFileMerger.Changes) {
        print("📊 Changes Summary")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🆕 New keys:      \(changes.new.count)")
        print("🔄 Modified:      \(changes.modified.count)")
        print("❌ Removed:       \(changes.removed.count)")
        print("💬 Comments:      \(changes.commentChanged.count)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")

        if !changes.new.isEmpty {
            print("🆕 New Keys:")
            for key in changes.new {
                print("   • \(key)")
            }
            print("")
        }

        if !changes.modified.isEmpty {
            print("🔄 Modified Keys:")
            for key in changes.modified {
                print("   • \(key)")
            }
            print("")
        }

        if !changes.removed.isEmpty {
            print("❌ Removed Keys:")
            for key in changes.removed {
                print("   • \(key)")
            }
            print("")
        }
    }
}
