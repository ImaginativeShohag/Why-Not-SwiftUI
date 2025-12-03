//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation

struct MigrateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "migrate",
        abstract: "Migrate v1 translation files to v2 format with per-key versioning"
    )

    @Option(name: .long, help: "Root directory of the project (default: current directory)")
    var projectPath: String = FileManager.default.currentDirectoryPath

    @Option(name: .long, help: "Base language file to use as source (default: en.json)")
    var baseLanguage: String = "en"

    @Flag(name: .long, help: "Create backup before migration")
    var backup: Bool = true

    @Flag(name: .long, help: "Verbose output")
    var verbose: Bool = false

    func run() async throws {
        let translationsDir = (projectPath as NSString).appendingPathComponent("Translations")

        print("\n🔄 Migrating LocalizeKit files from v1 to v2...\n")
        print("Project:       \(projectPath)")
        print("Translations:  \(translationsDir)")
        print("Base language: \(baseLanguage)")
        print("")

        do {
            let fileManager = FileManager.default

            // Check if Translations directory exists
            guard fileManager.fileExists(atPath: translationsDir) else {
                print("❌ Translations directory not found at: \(translationsDir)")
                throw ExitCode.failure
            }

            // Create backup if requested
            if backup {
                try createBackup(translationsDir: translationsDir)
            }

            // Find base language file
            let baseLangPath = (translationsDir as NSString).appendingPathComponent("\(baseLanguage).json")

            guard fileManager.fileExists(atPath: baseLangPath) else {
                print("❌ Base language file not found: \(baseLanguage).json")
                print("💡 Specify a different base language with --base-language")
                throw ExitCode.failure
            }

            // Load base language file
            print("📖 Loading base language file: \(baseLanguage).json\n")
            let baseLegacyFile = try loadLegacyFile(from: baseLangPath)

            // Convert to base.json (v2 format)
            print("🔄 Converting to base.json format...\n")
            let baseFile = try convertToBaseFile(baseLegacyFile)

            // Save base.json
            let baseOutputPath = (translationsDir as NSString).appendingPathComponent("base.json")
            try saveBaseFile(baseFile, to: baseOutputPath)
            print("✅ Created: base.json (v\(baseFile.version))")

            // Find all other language files
            let allFiles = try fileManager.contentsOfDirectory(atPath: translationsDir)
            let langFiles = allFiles
                .filter { $0.hasSuffix(".json") && $0 != "base.json" && $0 != "\(baseLanguage).json" }
                .map { $0.replacingOccurrences(of: ".json", with: "") }
                .sorted()

            if !langFiles.isEmpty {
                print("\n📋 Converting target language files: \(langFiles.joined(separator: ", "))\n")

                for lang in langFiles {
                    let langPath = (translationsDir as NSString).appendingPathComponent("\(lang).json")
                    try convertTargetLanguageFile(
                        language: lang,
                        filePath: langPath,
                        baseFile: baseFile
                    )
                }
            }

            // Summary
            print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("✅ Migration completed successfully!")
            print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            print("")
            print("Files created:")
            print("  • base.json (v\(baseFile.version))")
            for lang in langFiles {
                print("  • \(lang).json (simplified)")
            }
            print("")

            if backup {
                print("💾 Backup saved at: \(translationsDir).backup")
                print("")
            }

            print("📝 Next steps:")
            print("  1. Review the migrated files")
            print("  2. Test with: validate --all")
            print("  3. Remove old \(baseLanguage).json if everything looks good")
            print("")

        } catch let error as DecodingError {
            print("❌ Failed to parse translation file:")
            print("   \(error.localizedDescription)")
            throw ExitCode.failure
        } catch {
            print("❌ Migration failed: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }

    // MARK: - Private Methods

    private func createBackup(translationsDir: String) throws {
        let backupPath = "\(translationsDir).backup"
        let fileManager = FileManager.default

        // Remove existing backup if it exists
        if fileManager.fileExists(atPath: backupPath) {
            try fileManager.removeItem(atPath: backupPath)
        }

        // Copy directory
        try fileManager.copyItem(atPath: translationsDir, toPath: backupPath)

        if verbose {
            print("💾 Created backup at: \(backupPath)")
        }
        print("✅ Backup created\n")
    }

    private func loadLegacyFile(from path: String) throws -> TranslationFile {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(TranslationFile.self, from: data)
    }

    private func convertToBaseFile(_ legacyFile: TranslationFile) throws -> BaseTranslationFile {
        // Parse version string to int
        let versionInt: Int
        if let versionNum = Int(legacyFile.version) {
            versionInt = versionNum
        } else {
            // Try to extract version from semantic versioning (e.g., "1.0.0" -> 1)
            let components = legacyFile.version.split(separator: ".")
            if let firstComponent = components.first, let num = Int(firstComponent) {
                versionInt = num
            } else {
                versionInt = 1 // Default to 1
            }
        }

        var modules: [String: [String: BaseTranslationEntry]] = [:]

        for (moduleName, legacyStrings) in legacyFile.modules {
            var baseStrings: [String: BaseTranslationEntry] = [:]

            for (key, legacyEntry) in legacyStrings {
                // Convert metadata
                let addedInVersion: Int
                if let metadataVersion = legacyEntry.metadata?.addedInVersion {
                    addedInVersion = parseVersionString(metadataVersion)
                } else {
                    addedInVersion = versionInt
                }

                let lastModifiedVersion: Int?
                if let metadataLastModified = legacyEntry.metadata?.lastModifiedVersion {
                    lastModifiedVersion = parseVersionString(metadataLastModified)
                } else {
                    lastModifiedVersion = nil
                }

                // Use per-key version from metadata or file version
                let keyVersion = lastModifiedVersion ?? addedInVersion

                let entry = BaseTranslationEntry(
                    value: legacyEntry.value,
                    type: legacyEntry.type,
                    comment: legacyEntry.comment,
                    version: keyVersion,
                    metadata: BaseMetadata(
                        addedInVersion: addedInVersion,
                        lastModifiedVersion: lastModifiedVersion,
                        status: legacyEntry.metadata?.status ?? .unchanged
                    )
                )

                baseStrings[key] = entry
            }

            modules[moduleName] = baseStrings
        }

        let dateFormatter = ISO8601DateFormatter()
        let generatedAt = dateFormatter.string(from: Date())

        return BaseTranslationFile(
            version: versionInt,
            language: legacyFile.language,
            generatedAt: generatedAt,
            modules: modules
        )
    }

    private func convertTargetLanguageFile(
        language: String,
        filePath: String,
        baseFile: BaseTranslationFile
    ) throws {
        // Load legacy target file
        let legacyFile = try loadLegacyFile(from: filePath)

        // Convert to simplified target format
        var modules: [String: [String: TargetTranslationEntry]] = [:]

        for (moduleName, legacyStrings) in legacyFile.modules {
            var targetStrings: [String: TargetTranslationEntry] = [:]

            for (key, legacyEntry) in legacyStrings {
                let entry = TargetTranslationEntry(
                    value: legacyEntry.value,
                    type: legacyEntry.type
                )
                targetStrings[key] = entry
            }

            modules[moduleName] = targetStrings
        }

        let dateFormatter = ISO8601DateFormatter()
        let generatedAt = dateFormatter.string(from: Date())

        let targetFile = TargetTranslationFile(
            version: baseFile.version,
            language: language,
            generatedAt: generatedAt,
            modules: modules
        )

        // Save
        try saveTargetFile(targetFile, to: filePath)

        print("✅ Converted: \(language).json")
    }

    private func parseVersionString(_ versionString: String) -> Int {
        if let versionNum = Int(versionString) {
            return versionNum
        }

        // Try semantic versioning
        let components = versionString.split(separator: ".")
        if let firstComponent = components.first, let num = Int(firstComponent) {
            return num
        }

        return 1 // Default
    }

    private func saveBaseFile(_ file: BaseTranslationFile, to path: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(file)
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    }

    private func saveTargetFile(_ file: TargetTranslationFile, to path: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(file)
        try data.write(to: URL(fileURLWithPath: path), options: .atomic)
    }
}
