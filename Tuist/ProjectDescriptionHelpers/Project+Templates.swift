//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import ProjectDescription

/// Project helpers are functions that simplify the way you define your project.
/// Share code to create targets, settings, dependencies,
/// Create your own conventions, e.g: a func that makes sure all shared targets are "static frameworks"
/// See https://docs.tuist.io/guides/helpers/

public extension Project {
    static let bundleId = Constants.bundleId
    static let organizationName = Constants.organizationName

    /// Helper function to create the Project
    static func app(
        name: String,
        platform: Platform,
        deploymentTarget: ProjectDescription.DeploymentTarget,
        baseSettings: [String: SettingValue],
        additionalTargets: [Module],
        externalDependencies: [TargetDependency],
        infoPlist: [String: Plist.Value]
    ) -> Project {
        let appMainTarget: ProjectDescription.TargetReference = "\(name)"

        var dependencies: [TargetDependency] = additionalTargets
            .map { TargetDependency.target(name: $0.name) }
        dependencies.append(contentsOf: externalDependencies)
        dependencies.append(contentsOf: appExtensions.map { TargetDependency.target(name: $0.name) })

        var targets = makeAppTargets(
            name: name,
            platform: platform,
            deploymentTarget: deploymentTarget,
            dependencies: dependencies,
            infoPlist: infoPlist
        )
        targets += additionalTargets.flatMap {
            makeFrameworkTargets(
                module: $0,
                platform: platform,
                deploymentTarget: deploymentTarget,
                externalDependencies: externalDependencies
            )
        }
        targets.append(contentsOf: appExtensions)

        let targetNames = targets.filter { target in
            target.name.hasSuffix("Tests")
        }.map { target in
            TestableTarget(stringLiteral: target.name)
        }

        return Project(
            name: name,
            organizationName: organizationName,
            options: .options(
                automaticSchemesOptions: .disabled
            ),
            settings: .settings(
                base: baseSettings,
                configurations: BuildEnvironment.allConfigurations
            ),
            targets: targets,
            schemes: [
                Scheme(
                    name: "\(name) Development",
                    shared: true,
                    buildAction: .buildAction(targets: [appMainTarget]),
                    testAction: .targets(
                        targetNames,
                        configuration: BuildEnvironment.development.debugConfiguration.name
                    ),
                    runAction: .runAction(
                        configuration: BuildEnvironment.development.debugConfiguration.name,
                        executable: appMainTarget
                    ),
                    archiveAction: .archiveAction(
                        configuration: BuildEnvironment.development.releaseConfiguration.name
                    )
                ),
                Scheme(
                    name: "\(name) Staging",
                    shared: true,
                    buildAction: .buildAction(targets: [appMainTarget]),
                    testAction: .targets(
                        targetNames,
                        configuration: BuildEnvironment.staging.debugConfiguration.name
                    ),
                    runAction: .runAction(
                        configuration: BuildEnvironment.staging.debugConfiguration.name,
                        executable: appMainTarget
                    ),
                    archiveAction: .archiveAction(
                        configuration: BuildEnvironment.staging.releaseConfiguration.name
                    )
                ),
                Scheme(
                    name: "\(name) Production",
                    shared: true,
                    buildAction: .buildAction(targets: [appMainTarget]),
                    testAction: .targets(
                        targetNames,
                        configuration: BuildEnvironment.production.debugConfiguration.name
                    ),
                    runAction: .runAction(
                        configuration: BuildEnvironment.production.debugConfiguration.name,
                        executable: appMainTarget
                    ),
                    archiveAction: .archiveAction(
                        configuration: BuildEnvironment.production.releaseConfiguration.name
                    )
                )
            ]
        )
    }

    // MARK: - Private

    /// Helper function to create a framework target and an associated unit test target
    private static func makeFrameworkTargets(
        module: Module,
        platform: Platform,
        deploymentTarget: ProjectDescription.DeploymentTarget,
        externalDependencies: [TargetDependency]
    ) -> [Target] {
        let name = module.name

        // Resources
        var resources: ProjectDescription.ResourceFileElements?

        if module.hasResources {
            resources = ["Targets/\(name)/Resources/**"]
        }

        // Dependencies
        var dependencies: [TargetDependency] = .init(externalDependencies)

        if !module.dependencies.isEmpty {
            dependencies += module.dependencies.map { .target(name: $0) }
        }

        let sources = Target(
            name: name,
            platform: platform,
            product: .framework,
            bundleId: "\(bundleId).\(name)",
            deploymentTarget: deploymentTarget,
            infoPlist: .default,
            sources: ["Targets/\(name)/Sources/**"],
            resources: resources,
            dependencies: dependencies,
            settings: .settings(
                configurations: TargetBuildEnvironment.allConfigurations
            )
        )
        
        let tests = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "\(bundleId).\(name)Tests",
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            resources: [],
            dependencies: [.target(name: name)],
            settings: .settings(
                configurations: TargetBuildEnvironment.allConfigurations
            )
        )
        
        let uiTests = Target(
            name: "\(name)UITests",
            platform: platform,
            product: .uiTests,
            bundleId: "\(bundleId).\(name)UITests",
            infoPlist: .default,
            sources: ["Targets/\(name)/UITests/**"],
            resources: [],
            dependencies: [.target(name: name)],
            settings: .settings(
                configurations: TargetBuildEnvironment.allConfigurations
            )
        )
        
        return [sources, tests, uiTests]
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(
        name: String,
        platform: Platform,
        deploymentTarget: ProjectDescription.DeploymentTarget,
        dependencies: [TargetDependency],
        infoPlist: [String: Plist.Value]
    ) -> [Target] {
        let platform: Platform = platform

        let mainTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: bundleId,
            deploymentTarget: deploymentTarget,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            entitlements: "Entitlements/\(name).entitlements",
            dependencies: dependencies,
            settings: .settings(
                configurations: BuildEnvironment.allConfigurations
            )
        )

        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "\(bundleId).\(name)Tests",
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            dependencies: [
                .target(name: "\(name)")
            ],
            settings: .settings(
                configurations: BuildEnvironment.allConfigurations
            )
        )
        
        let uiTestTarget = Target(
            name: "\(name)UITests",
            platform: platform,
            product: .uiTests,
            bundleId: "\(bundleId).\(name)UITests",
            infoPlist: .default,
            sources: ["Targets/\(name)/UITests/**"],
            dependencies: [
                .target(name: "\(name)")
            ],
            settings: .settings(
                configurations: BuildEnvironment.allConfigurations
            )
        )
        
        return [mainTarget, testTarget, uiTestTarget]
    }
}
