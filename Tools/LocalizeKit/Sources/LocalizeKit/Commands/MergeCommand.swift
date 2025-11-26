//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation

struct MergeCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "merge",
        abstract: "Merge new extracted strings with existing translations"
    )

    @Option(name: .long, help: "Path to the new extracted translation file")
    var newFile: String

    @Option(name: .long, help: "Path to the existing translation file")
    var existingFile: String

    @Option(name: .long, help: "Output path for the merged translation file")
    var outputPath: String

    @Flag(name: .long, help: "Keep removed strings in the output")
    var keepRemoved: Bool = false

    @Flag(name: .long, help: "Verbose output")
    var verbose: Bool = false

    func run() async throws {
        print("\n🔀 Merging translations...\n")
        print("New file:      \(newFile)")
        print("Existing file: \(existingFile)")
        print("Output:        \(outputPath)")
        print("Keep removed:  \(keepRemoved ? "Yes" : "No")")
        print("")

        do {
            let merger = TranslationMerger(keepRemoved: keepRemoved, verbose: verbose)

            // Load files
            if verbose {
                print("📖 Loading translation files...")
            }

            let newTranslations = try merger.loadTranslationFile(from: newFile)
            let existingTranslations = try merger.loadTranslationFile(from: existingFile)

            // Validate language codes match
            guard newTranslations.language == existingTranslations.language else {
                print("❌ Language mismatch:")
                print("   New file:      \(newTranslations.language)")
                print("   Existing file: \(existingTranslations.language)")
                throw ExitCode.failure
            }

            // Merge
            if verbose {
                print("🔄 Merging translations...")
            }

            let merged = merger.merge(newFile: newTranslations, existingFile: existingTranslations)

            // Save
            try merger.saveTranslationFile(merged, to: outputPath)

            print("✅ Merge completed successfully!")
            print("📄 Output file: \(outputPath)\n")

        } catch let error as DecodingError {
            print("❌ Failed to parse translation file:")
            print("   \(error.localizedDescription)")
            throw ExitCode.failure
        } catch {
            print("❌ Merge failed: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }
}
