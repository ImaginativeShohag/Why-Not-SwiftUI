//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation

struct ExtractCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "extract",
        abstract: "Extract localization strings from Swift files"
    )

    @Option(name: .long, help: "Root directory of the project (default: current directory)")
    var projectPath: String = FileManager.default.currentDirectoryPath

    @Option(name: .long, help: "Output directory for generated JSON files (default: ./Translations)")
    var outputPath: String = "./Translations"

    @Option(name: .long, help: "Language code for the extracted strings (default: en)")
    var language: String = "en"

    @Option(name: .long, help: "Version string for the translation file")
    var version: String

    @Flag(name: .long, help: "Verbose output")
    var verbose: Bool = false

    func run() async throws {
        print("\n🔍 Extracting localization strings...\n")
        print("Project:  \(projectPath)")
        print("Output:   \(outputPath)")
        print("Language: \(language)")
        print("Version:  \(version)")
        print("")

        do {
            // Extract strings
            let extractor = StringExtractor(projectPath: projectPath, verbose: verbose)
            let extractedStrings = try extractor.extract()

            guard !extractedStrings.isEmpty else {
                print("⚠️  No localization strings found in the project.")
                print("💡 Make sure you're using the .localize() extension methods.")
                throw ExitCode.failure
            }

            // Generate translation file
            let generator = TranslationFileGenerator(
                version: version,
                language: language,
                verbose: verbose
            )

            let translationFile = generator.generate(from: extractedStrings)

            // Create output file path
            let fileName = "\(language).json"
            let fullOutputPath = (outputPath as NSString).appendingPathComponent(fileName)

            // Save to disk
            try generator.save(translationFile, to: fullOutputPath)

            // Print summary
            print(generator.generateSummary(from: translationFile))

            print("✅ Extraction completed successfully!")
            print("📄 Output file: \(fullOutputPath)\n")

        } catch let error as ExtractionError {
            print("❌ Extraction failed: \(error.localizedDescription)")
            throw ExitCode.failure
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }
}
