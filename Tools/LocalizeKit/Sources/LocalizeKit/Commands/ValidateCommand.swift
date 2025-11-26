//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation

struct ValidateCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate translation files for completeness and correctness"
    )

    @Option(name: .long, help: "Path to the translation file to validate")
    var filePath: String

    @Option(name: .long, help: "Base language file path for comparison (optional)")
    var basePath: String?

    @Flag(name: .long, help: "Check for missing translations")
    var checkMissing: Bool = true

    @Flag(name: .long, help: "Check for format string mismatches")
    var checkFormat: Bool = true

    @Flag(name: .long, help: "Check for plural forms")
    var checkPlurals: Bool = true

    @Flag(name: .long, help: "Verbose output")
    var verbose: Bool = false

    func run() async throws {
        print("\n✅ Validating translation file...\n")
        print("File:      \(filePath)")
        if let basePath = basePath {
            print("Base file: \(basePath)")
        }
        print("")

        do {
            let validator = TranslationValidator(verbose: verbose)

            // Load file
            let url = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: url)
            let translationFile = try JSONDecoder().decode(TranslationFile.self, from: data)

            if verbose {
                print("📊 Validating \(translationFile.language) translation...")
                print("   Version: \(translationFile.version)")
                print("   Modules: \(translationFile.modules.count)")
                print("")
            }

            // Validate
            let result = try validator.validate(
                file: translationFile,
                basePath: basePath,
                checkMissing: checkMissing,
                checkFormat: checkFormat,
                checkPlurals: checkPlurals
            )

            // Print report
            let fileName = (filePath as NSString).lastPathComponent
            validator.printReport(result, fileName: fileName)

            if result.isValid {
                print("✅ Validation passed!\n")
            } else {
                print("❌ Validation failed with errors.\n")
                throw ExitCode.failure
            }

        } catch let error as DecodingError {
            print("❌ Failed to parse translation file:")
            print("   \(error.localizedDescription)")
            throw ExitCode.failure
        } catch {
            print("❌ Validation error: \(error.localizedDescription)")
            throw ExitCode.failure
        }
    }
}
