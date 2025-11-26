//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation

struct DiffCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "diff",
        abstract: "Generate a diff file between two translation versions"
    )

    @Option(name: .long, help: "Path to the old translation file")
    var oldFile: String

    @Option(name: .long, help: "Path to the new translation file")
    var newFile: String

    @Option(name: .long, help: "Output path for the diff file")
    var outputPath: String

    @Option(name: .long, help: "Output format (json or markdown)")
    var format: String = "json"

    @Flag(name: .long, help: "Verbose output")
    var verbose: Bool = false

    func run() async throws {
        print("\n📊 Generating diff between versions...\n")
        print("Old file: \(oldFile)")
        print("New file: \(newFile)")
        print("Output:   \(outputPath)")
        print("Format:   \(format)")
        print("")

        // Validate format
        guard format == "json" || format == "markdown" else {
            print("❌ Invalid format: \(format)")
            print("   Supported formats: json, markdown")
            throw ExitCode.failure
        }

        do {
            let generator = DiffGenerator(verbose: verbose)

            // Load files
            if verbose {
                print("📖 Loading translation files...")
            }

            let oldTranslations = try generator.loadTranslationFile(from: oldFile)
            let newTranslations = try generator.loadTranslationFile(from: newFile)

            // Validate language codes match
            guard oldTranslations.language == newTranslations.language else {
                print("❌ Language mismatch:")
                print("   Old file: \(oldTranslations.language)")
                print("   New file: \(newTranslations.language)")
                throw ExitCode.failure
            }

            // Generate diff
            if verbose {
                print("🔄 Generating diff...")
            }

            let diffFile = generator.generateDiff(oldFile: oldTranslations, newFile: newTranslations)

            // Save based on format
            if format == "json" {
                try generator.saveDiffJSON(diffFile, to: outputPath)
            } else {
                try generator.saveDiffMarkdown(diffFile, to: outputPath)
            }

            // Print summary
            generator.printSummary(diffFile)

            print("✅ Diff generated successfully!")
            print("📄 Output file: \(outputPath)\n")

        } catch let error as DecodingError {
            print("❌ Failed to parse translation file:")
            print("   \(error.localizedDescription)")
            throw ExitCode.failure
        } catch {
            print("❌ Diff generation failed: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }
}
