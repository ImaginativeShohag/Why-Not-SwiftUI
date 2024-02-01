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
    ///
    /// - Parameters:
    ///   - name: Name of the app.
    ///   - deploymentTargets: Deployment targets.
    ///   - destinations: Deployment destinations.
    ///   - baseSettings: Base Xcode settings.
    ///   - infoPlist: Information property list.
    ///   - configInfoPlist: Information property list that only contains configuration mappings from `.xcconfig` configuration files.
    ///   - modules: All module list.
    ///   - externalDependencies: External dependency list.
    ///   - coreDataModels: Core Data models for main target.
    /// - Returns: the project.
    static func app(
        name: String,
        deploymentTargets: DeploymentTargets,
        destinations: Destinations,
        baseSettings: [String: SettingValue],
        infoPlist: [String: Plist.Value],
        configInfoPlist: [String: Plist.Value],
        modules: [Module],
        externalDependencies: [TargetDependency],
        coreDataModels: [Path]
    ) -> Project {
        let appMainTarget: ProjectDescription.TargetReference = "\(name)"

        var dependencies: [TargetDependency] = modules
            .map { TargetDependency.target(name: $0.name) }
        dependencies.append(contentsOf: externalDependencies)
        dependencies.append(contentsOf: appExtensions.map { TargetDependency.target(name: $0.name) })

        var finalInfoPlist = infoPlist.merging(configInfoPlist) { _, new in new }

        var targets = makeAppTargets(
            name: name,
            destinations: destinations,
            deploymentTargets: deploymentTargets,
            dependencies: dependencies,
            infoPlist: finalInfoPlist,
            coreDataModels: coreDataModels
        )
        targets += modules.flatMap {
            makeFrameworkTargets(
                appTargetName: name,
                module: $0,
                destinations: destinations,
                deploymentTargets: deploymentTargets,
                externalDependencies: externalDependencies,
                infoPlist: configInfoPlist
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
                configurations: BuildEnvironment.getConfigurations(for: .app)
            ),
            targets: targets,
            schemes: [
                Scheme(
                    name: "\(name) Development",
                    shared: true,
                    buildAction: .buildAction(targets: [appMainTarget]),
                    testAction: .targets(
                        targetNames,
                        configuration: BuildEnvironment.development.name(variant: .debug)
                    ),
                    runAction: .runAction(
                        configuration: BuildEnvironment.development.name(variant: .debug),
                        executable: appMainTarget
                    ),
                    archiveAction: .archiveAction(
                        configuration: BuildEnvironment.development.name(variant: .release)
                    )
                ),
                Scheme(
                    name: "\(name) Staging",
                    shared: true,
                    buildAction: .buildAction(targets: [appMainTarget]),
                    testAction: .targets(
                        targetNames,
                        configuration: BuildEnvironment.staging.name(variant: .debug)
                    ),
                    runAction: .runAction(
                        configuration: BuildEnvironment.staging.name(variant: .debug),
                        executable: appMainTarget
                    ),
                    archiveAction: .archiveAction(
                        configuration: BuildEnvironment.staging.name(variant: .release)
                    )
                ),
                Scheme(
                    name: "\(name) Production",
                    shared: true,
                    buildAction: .buildAction(targets: [appMainTarget]),
                    testAction: .targets(
                        targetNames,
                        configuration: BuildEnvironment.production.name(variant: .debug)
                    ),
                    runAction: .runAction(
                        configuration: BuildEnvironment.production.name(variant: .debug),
                        executable: appMainTarget
                    ),
                    archiveAction: .archiveAction(
                        configuration: BuildEnvironment.production.name(variant: .release)
                    )
                )
            ]
        )
    }

    // MARK: - Private

    /// Helper function to create a framework target and an associated unit test target
    private static func makeFrameworkTargets(
        appTargetName: String,
        module: Module,
        destinations: Destinations,
        deploymentTargets: DeploymentTargets,
        externalDependencies: [TargetDependency],
        infoPlist: [String: Plist.Value]
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

        // Core Data
        let coreDataModels = module.coreDataModels.map { CoreDataModel($0) }

        let sources = Target(
            name: name,
            destinations: destinations,
            product: .framework,
            bundleId: "\(bundleId).\(name)",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/\(name)/Sources/**"],
            resources: resources,
            dependencies: dependencies,
            settings: .settings(
                configurations: BuildEnvironment.getConfigurations(for: .target)
            ),
            coreDataModels: coreDataModels
        )

        var tests: Target?

        if module.hasUnitTest {
            // Resources
            var resources: ProjectDescription.ResourceFileElements?

            if module.hasUnitTestResources {
                resources = ["Targets/\(name)/Tests/Resources/**"]
            }

            tests = Target(
                name: "\(name)Tests",
                destinations: destinations,
                product: .unitTests,
                bundleId: "\(bundleId).\(name)Tests",
                deploymentTargets: deploymentTargets,
                infoPlist: .extendingDefault(with: infoPlist),
                sources: ["Targets/\(name)/Tests/**"],
                resources: resources,
                dependencies: [.target(name: appTargetName), .target(name: name)],
                settings: .settings(
                    configurations: BuildEnvironment.getConfigurations(for: .unitTest)
                )
            )
        }

        var uiTests: Target?

        if module.hasUITest {
            // Resources
            var resources: ProjectDescription.ResourceFileElements?

            if module.hasUITestResources {
                resources = ["Targets/\(name)/UITests/Resources/**"]
            }

            uiTests = Target(
                name: "\(name)UITests",
                destinations: destinations,
                product: .uiTests,
                bundleId: "\(bundleId).\(name)UITests",
                deploymentTargets: deploymentTargets,
                infoPlist: .extendingDefault(with: infoPlist),
                sources: ["Targets/\(name)/UITests/**"],
                resources: resources,
                // Here the target will be the main app target.
                // Because UI test will run on the app itself.
                dependencies: [.target(name: appTargetName)],
                settings: .settings(
                    configurations: BuildEnvironment.getConfigurations(for: .target)
                )
            )
        }

        return [sources, tests, uiTests].compactMap { $0 }
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(
        name: String,
        destinations: Destinations,
        deploymentTargets: DeploymentTargets,
        dependencies: [TargetDependency],
        infoPlist: [String: Plist.Value],
        coreDataModels: [Path]
    ) -> [Target] {
        let coreDataModels = coreDataModels.map { CoreDataModel($0) }

        let mainTarget = Target(
            name: name,
            destinations: destinations,
            product: .app,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            entitlements: "Entitlements/\(name).entitlements",
            dependencies: dependencies,
            settings: .settings(
                configurations: BuildEnvironment.getConfigurations(for: .app)
            ),
            coreDataModels: coreDataModels
        )

        let testTarget = Target(
            name: "\(name)Tests",
            destinations: destinations,
            product: .unitTests,
            bundleId: "\(bundleId).\(name)Tests",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/\(name)/Tests/**"],
            dependencies: [
                .target(name: name)
            ],
            settings: .settings(
                configurations: BuildEnvironment.getConfigurations(for: .unitTest)
            )
        )

        let uiTestTarget = Target(
            name: "\(name)UITests",
            destinations: destinations,
            product: .uiTests,
            bundleId: "\(bundleId).\(name)UITests",
            deploymentTargets: deploymentTargets,
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/\(name)/UITests/**"],
            dependencies: [
                .target(name: name)
            ],
            settings: .settings(
                configurations: BuildEnvironment.getConfigurations(for: .target)
            )
        )

        return [mainTarget, testTarget, uiTestTarget]
    }
}
