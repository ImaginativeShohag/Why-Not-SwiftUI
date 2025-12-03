//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ArgumentParser
import Foundation

@main
struct LocalizeKit: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "localizekit",
        abstract: "Translation management tool for SwiftUI projects",
        version: "1.0.0",
        subcommands: [
            ExtractCommand.self,
            MergeCommand.self,
            ValidateCommand.self,
            DiffCommand.self,
            MenuCommand.self
        ],
        defaultSubcommand: MenuCommand.self
    )
}
