//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation
import LocalizeKitCore

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

        1. Extract strings from project → Updates base.json
        2. Merge translations → Sync target languages with base
        3. Validate translations → Check for issues
        4. Preview diff → See what needs translation
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

        print("Skip comment change prompts? (y/N): ", terminator: "")
        let skipPrompt = readLine()?.lowercased() ?? "n"
        let ignoreCommentChanges = (skipPrompt == "y" || skipPrompt == "yes")

        var command = ExtractCommand()
        command.projectPath = finalProjectPath
        command.ignoreCommentChanges = ignoreCommentChanges
        command.verbose = false

        try await command.run()
    }

    private func runMergeWizard() async throws {
        print("\n🔀 Merge Translations Wizard\n")

        print("Enter project path (press Enter for current directory): ", terminator: "")
        let projectPath = readLine() ?? FileManager.default.currentDirectoryPath
        let finalProjectPath = projectPath.isEmpty ? FileManager.default.currentDirectoryPath : projectPath

        print("Merge all languages? (y/N): ", terminator: "")
        let mergeAll = readLine()?.lowercased() ?? "n"

        var languages: [String] = []
        if mergeAll != "y" && mergeAll != "yes" {
            print("Enter language codes (comma-separated, e.g., ar,bn,es): ", terminator: "")
            guard let langInput = readLine(), !langInput.isEmpty else {
                print("❌ At least one language is required, or use --all flag.")
                throw ExitCode.failure
            }
            languages = langInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }

        var command = MergeCommand()
        command.projectPath = finalProjectPath
        if mergeAll == "y" || mergeAll == "yes" {
            command.all = true
        } else {
            command.language = languages
        }
        command.verbose = false

        try await command.run()
    }

    private func runValidateWizard() async throws {
        print("\n✅ Validate Translation File Wizard\n")

        print("Enter project path (press Enter for current directory): ", terminator: "")
        let projectPath = readLine() ?? FileManager.default.currentDirectoryPath
        let finalProjectPath = projectPath.isEmpty ? FileManager.default.currentDirectoryPath : projectPath

        print("Validate all languages? (y/N): ", terminator: "")
        let validateAll = readLine()?.lowercased() ?? "n"

        var languages: [String] = []
        if validateAll != "y" && validateAll != "yes" {
            print("Enter language codes (comma-separated, e.g., ar,bn,es): ", terminator: "")
            guard let langInput = readLine(), !langInput.isEmpty else {
                print("❌ At least one language is required, or use --all flag.")
                throw ExitCode.failure
            }
            languages = langInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }

        var command = ValidateCommand()
        command.projectPath = finalProjectPath
        if validateAll == "y" || validateAll == "yes" {
            command.all = true
        } else {
            command.language = languages
        }
        command.checkMissing = true
        command.checkFormat = true
        command.checkPlurals = true
        command.verbose = false

        try await command.run()
    }

    private func runDiffWizard() async throws {
        print("\n📊 Preview Translation Diff Wizard\n")

        print("Enter project path (press Enter for current directory): ", terminator: "")
        let projectPath = readLine() ?? FileManager.default.currentDirectoryPath
        let finalProjectPath = projectPath.isEmpty ? FileManager.default.currentDirectoryPath : projectPath

        print("Compare all languages? (y/N): ", terminator: "")
        let compareAll = readLine()?.lowercased() ?? "n"

        var languages: [String] = []
        if compareAll != "y" && compareAll != "yes" {
            print("Enter language codes (comma-separated, e.g., ar,bn,es): ", terminator: "")
            guard let langInput = readLine(), !langInput.isEmpty else {
                print("❌ At least one language is required, or use --all flag.")
                throw ExitCode.failure
            }
            languages = langInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        }

        var command = DiffCommand()
        command.projectPath = finalProjectPath
        if compareAll == "y" || compareAll == "yes" {
            command.all = true
        } else {
            command.language = languages
        }
        command.verbose = false

        try await command.run()
    }
}
