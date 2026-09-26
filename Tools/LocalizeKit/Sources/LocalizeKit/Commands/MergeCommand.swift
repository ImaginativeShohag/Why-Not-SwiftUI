//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation
import LocalizeKitCore

struct MergeCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "merge",
        abstract: "Sync target language files with base.json"
    )

    @Option(name: .long, help: "Target language code(s) to merge (repeatable)")
    var language: [String] = []

    @Flag(name: .long, help: "Merge all available language files")
    var all: Bool = false

    @Option(name: .long, help: "Root directory of the project (default: current directory)")
    var projectPath: String = FileManager.default.currentDirectoryPath

    @Flag(name: .long, help: "Verbose output")
    var verbose: Bool = false

    func run() async throws {
        let translationsDir = (projectPath as NSString).appendingPathComponent("Translations")
        let basePath = (translationsDir as NSString).appendingPathComponent("base.json")

        print("\n🔀 Merging translations...\n")
        print("Project:       \(projectPath)")
        print("Translations:  \(translationsDir)")
        print("")

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

            print("📋 Target languages: \(targetLanguages.joined(separator: ", "))\n")

            // Merge each language
            for lang in targetLanguages {
                try await mergeLanguage(
                    language: lang,
                    baseFile: baseFile,
                    translationsDir: translationsDir
                )
            }

            print("\n✅ All merges completed successfully!\n")

        } catch let error as DecodingError {
            print("❌ Failed to parse translation file:")
            print("   \(error.localizedDescription)")
            throw ExitCode.failure
        } catch {
            print("❌ Merge failed: \(error.localizedDescription)")
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

    private func mergeLanguage(
        language: String,
        baseFile: BaseTranslationFile,
        translationsDir: String
    ) async throws {
        let targetPath = (translationsDir as NSString).appendingPathComponent("\(language).json")

        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🌐 Language: \(language)")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

        let merger = LanguageMerger()

        if FileManager.default.fileExists(atPath: targetPath) {
            // Sync existing file
            if verbose {
                print("📖 Loading existing \(language).json...")
            }

            let targetFile = try merger.loadTargetFile(from: targetPath)

            if verbose {
                print("🔄 Syncing with base.json (v\(baseFile.version))...")
            }

            let updated = merger.sync(
                base: baseFile,
                target: targetFile
            )

            try merger.saveTargetFile(updated, to: targetPath)

            print("✅ Synced \(language).json")
            printMergeSummary(language: language, changes: merger.changes)

        } else {
            // Create new file from base
            if verbose {
                print("📝 Creating new \(language).json from base...")
            }

            let newFile = merger.createFromBase(
                base: baseFile,
                language: language
            )

            try merger.saveTargetFile(newFile, to: targetPath)

            print("✅ Created \(language).json")
            printMergeSummary(language: language, changes: merger.changes)
        }

        print("")
    }

    private func printMergeSummary(language: String, changes: LanguageMerger.Changes) {
        print("📊 Changes:")
        print("   🆕 Added:   \(changes.added.count)")
        print("   🔄 Updated: \(changes.updated.count)")
        print("   ❌ Removed: \(changes.removed.count)")
        print("   ✅ Kept:    \(changes.kept.count)")

        if !changes.added.isEmpty && verbose {
            print("\n   New keys:")
            for key in changes.added.prefix(5) {
                print("     • \(key)")
            }
            if changes.added.count > 5 {
                print("     ... and \(changes.added.count - 5) more")
            }
        }

        if !changes.updated.isEmpty && verbose {
            print("\n   Updated keys:")
            for key in changes.updated.prefix(5) {
                print("     • \(key)")
            }
            if changes.updated.count > 5 {
                print("     ... and \(changes.updated.count - 5) more")
            }
        }

        if !changes.removed.isEmpty {
            print("\n   ⚠️  Removed from base:")
            for key in changes.removed {
                print("     • \(key)")
            }
        }
    }

    private func loadBaseFile(from path: String) throws -> BaseTranslationFile {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(BaseTranslationFile.self, from: data)
    }
}
