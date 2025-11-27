//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation

struct MenuCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "menu",
        abstract: "Interactive menu for translation management"
    )

    func run() async throws {
        print("""

        ╔═══════════════════════════════════════════════════════╗
        ║         LocalizeKit - Translation Manager            ║
        ║                     v1.0.0                           ║
        ╚═══════════════════════════════════════════════════════╝

        Please select an option:

        1. Extract strings from project
        2. Merge extracted strings with existing translations
        3. Validate translation files
        4. Generate diff between versions
        5. Exit

        """)

        print("Enter your choice (1-5): ", terminator: "")

        guard let input = readLine(),
              let choice = Int(input) else {
            print("❌ Invalid input. Please enter a number between 1 and 5.")
            throw ExitCode.failure
        }

        switch choice {
        case 1:
            try await runExtractWizard()
        case 2:
            try await runMergeWizard()
        case 3:
            try await runValidateWizard()
        case 4:
            try await runDiffWizard()
        case 5:
            print("👋 Goodbye!")
            throw ExitCode.success
        default:
            print("❌ Invalid choice. Please select a number between 1 and 5.")
            throw ExitCode.failure
        }
    }

    // MARK: - Wizards

    private func runExtractWizard() async throws {
        print("\n📝 Extract Strings Wizard\n")

        print("Enter project path (press Enter for current directory): ", terminator: "")
        let projectPath = readLine() ?? FileManager.default.currentDirectoryPath
        let finalProjectPath = projectPath.isEmpty ? FileManager.default.currentDirectoryPath : projectPath

        print("Enter output path (press Enter for ./Translations): ", terminator: "")
        let outputPath = readLine() ?? "./Translations"
        let finalOutputPath = outputPath.isEmpty ? "./Translations" : outputPath

        print("Enter language code (press Enter for 'en'): ", terminator: "")
        let language = readLine() ?? "en"
        let finalLanguage = language.isEmpty ? "en" : language

        print("Enter version (required): ", terminator: "")
        guard let version = readLine(), !version.isEmpty else {
            print("❌ Version is required.")
            throw ExitCode.failure
        }

        var command = ExtractCommand()
        command.projectPath = finalProjectPath
        command.outputPath = finalOutputPath
        command.language = finalLanguage
        command.version = version
        command.verbose = false

        try await command.run()
    }

    private func runMergeWizard() async throws {
        print("\n🔀 Merge Translations Wizard\n")

        print("Enter path to new extracted file: ", terminator: "")
        guard let newFile = readLine(), !newFile.isEmpty else {
            print("❌ New file path is required.")
            throw ExitCode.failure
        }

        print("Enter path to existing translation file: ", terminator: "")
        guard let existingFile = readLine(), !existingFile.isEmpty else {
            print("❌ Existing file path is required.")
            throw ExitCode.failure
        }

        print("Enter output path: ", terminator: "")
        guard let outputPath = readLine(), !outputPath.isEmpty else {
            print("❌ Output path is required.")
            throw ExitCode.failure
        }

        print("Keep removed strings? (y/n, press Enter for 'n'): ", terminator: "")
        let keepRemovedInput = readLine() ?? "n"
        let keepRemoved = keepRemovedInput.lowercased() == "y"

        var command = MergeCommand()
        command.newFile = newFile
        command.existingFile = existingFile
        command.outputPath = outputPath
        command.keepRemoved = keepRemoved
        command.verbose = false

        try await command.run()
    }

    private func runValidateWizard() async throws {
        print("\n✅ Validate Translation File Wizard\n")

        print("Enter path to translation file: ", terminator: "")
        guard let filePath = readLine(), !filePath.isEmpty else {
            print("❌ File path is required.")
            throw ExitCode.failure
        }

        print("Enter base file path for comparison (press Enter to skip): ", terminator: "")
        let basePathInput = readLine()
        let basePath = basePathInput?.isEmpty == false ? basePathInput : nil

        var command = ValidateCommand()
        command.filePath = filePath
        command.basePath = basePath
        command.checkMissing = true
        command.checkFormat = true
        command.checkPlurals = true
        command.verbose = false

        try await command.run()
    }

    private func runDiffWizard() async throws {
        print("\n📊 Generate Diff Wizard\n")

        print("Enter path to old translation file: ", terminator: "")
        guard let oldFile = readLine(), !oldFile.isEmpty else {
            print("❌ Old file path is required.")
            throw ExitCode.failure
        }

        print("Enter path to new translation file: ", terminator: "")
        guard let newFile = readLine(), !newFile.isEmpty else {
            print("❌ New file path is required.")
            throw ExitCode.failure
        }

        print("Enter output path: ", terminator: "")
        guard let outputPath = readLine(), !outputPath.isEmpty else {
            print("❌ Output path is required.")
            throw ExitCode.failure
        }

        print("Enter output format (json/markdown, press Enter for 'json'): ", terminator: "")
        let formatInput = readLine() ?? "json"
        let format = formatInput.isEmpty ? "json" : formatInput

        var command = DiffCommand()
        command.oldFile = oldFile
        command.newFile = newFile
        command.outputPath = outputPath
        command.format = format
        command.verbose = false

        try await command.run()
    }
}
