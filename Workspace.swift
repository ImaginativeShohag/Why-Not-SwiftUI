//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription
import ProjectDescriptionHelpers

/// - Note: To disable the default workspace schema, this file is needed with `autogeneratedWorkspaceSchemes: .disabled` option.
let workspace = Workspace(
    name: "Why Not SwiftUI!",
    projects: [
        "."
    ],
    additionalFiles: [
        "README.md",
        "Tuist/ProjectDescriptionHelpers/Versions.swift"
    ],
    generationOptions: .options(
        autogeneratedWorkspaceSchemes: .disabled,
        renderMarkdownReadme: false
    )
)
