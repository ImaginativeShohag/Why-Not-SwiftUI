//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription

public struct Module {
    let name: String
    let hasResources: Bool
    let hasUnitTest: Bool
    let hasUnitTestResources: Bool
    let hasUITest: Bool
    let hasUITestResources: Bool
    let dependencies: [String]
    let coreDataModels: [Path]

    public init(
        name: String,
        hasResources: Bool = false,
        hasUnitTest: Bool = false,
        hasUnitTestResources: Bool = false,
        hasUITest: Bool = false,
        hasUITestResources: Bool = false,
        dependencies: [String] = [],
        coreDataModels: [Path] = []
    ) {
        self.name = name
        self.hasResources = hasResources
        self.hasUnitTest = hasUnitTest
        self.hasUnitTestResources = hasUnitTestResources
        self.hasUITest = hasUITest
        self.hasUITestResources = hasUITestResources
        self.dependencies = dependencies
        self.coreDataModels = coreDataModels
    }
}
