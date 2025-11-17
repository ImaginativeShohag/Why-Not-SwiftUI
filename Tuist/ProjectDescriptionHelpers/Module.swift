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
    let dependencies: [TargetDependency]
    let unitTestDependencies: [TargetDependency]
    let uiTestDependencies: [TargetDependency]
    let coreDataModels: [CoreDataModel]
    let onlyForTestTarget: Bool

    public init(
        name: String,
        hasResources: Bool = false,
        hasUnitTest: Bool = false,
        hasUnitTestResources: Bool = false,
        hasUITest: Bool = false,
        hasUITestResources: Bool = false,
        dependencies: [TargetDependency] = [],
        unitTestDependencies: [TargetDependency] = [],
        uiTestDependencies: [TargetDependency] = [],
        coreDataModels: [CoreDataModel] = [],
        onlyForTestTarget: Bool = false
    ) {
        self.name = name
        self.hasResources = hasResources
        self.hasUnitTest = hasUnitTest
        self.hasUnitTestResources = hasUnitTestResources
        self.hasUITest = hasUITest
        self.hasUITestResources = hasUITestResources
        self.dependencies = dependencies
        self.unitTestDependencies = unitTestDependencies
        self.uiTestDependencies = uiTestDependencies
        self.coreDataModels = coreDataModels
        self.onlyForTestTarget = onlyForTestTarget
    }
}

public struct AppModuleConfig {
    let hasResources: Bool
    let hasUnitTest: Bool
    let hasUnitTestResources: Bool
    let hasUITest: Bool
    let hasUITestResources: Bool
    let unitTestDependencies: [TargetDependency]
    let uiTestDependencies: [TargetDependency]
    let coreDataModels: [CoreDataModel]

    public init(
        hasResources: Bool = false,
        hasUnitTest: Bool = false,
        hasUnitTestResources: Bool = false,
        hasUITest: Bool = false,
        hasUITestResources: Bool = false,
        unitTestDependencies: [TargetDependency] = [],
        uiTestDependencies: [TargetDependency] = [],
        coreDataModels: [CoreDataModel] = []
    ) {
        self.hasResources = hasResources
        self.hasUnitTest = hasUnitTest
        self.hasUnitTestResources = hasUnitTestResources
        self.hasUITest = hasUITest
        self.hasUITestResources = hasUITestResources
        self.unitTestDependencies = unitTestDependencies
        self.uiTestDependencies = uiTestDependencies
        self.coreDataModels = coreDataModels
    }
}
