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
        appModuleConfig: AppModuleConfig,
        modules: [Module],
        externalDependencies: [TargetDependency]
    ) -> Project {
        let appMainTarget: ProjectDescription.TargetReference = "\(name)"

        var appTargetDependencies: [TargetDependency] = modules
            .filter { $0.onlyForTestTarget == false }
            .map { TargetDependency.target(name: $0.name) }
        appTargetDependencies.append(contentsOf: externalDependencies)
        appTargetDependencies.append(contentsOf: appExtensions.map { TargetDependency.target(name: $0.name) })

        let finalInfoPlist = infoPlist.merging(configInfoPlist) { _, new in new }

        var targets = makeAppTargets(
            name: name,
            config: appModuleConfig,
            destinations: destinations,
            deploymentTargets: deploymentTargets,
            dependencies: appTargetDependencies,
            infoPlist: finalInfoPlist
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
                automaticSchemesOptions: .disabled,
                defaultKnownRegions: ["Base", "en", "bn", "ja", "de", "fr", "hi", "it", "es", "sv", "ar", "zh", "ko", "nl", "th", "ms", "pt", "tr"]
            ),
            settings: .settings(
                base: baseSettings,
                configurations: BuildEnvironment.getConfigurations(for: .app),
                defaultConfiguration: "Debug Development"
            ),
            targets: targets,
            schemes: [
                .scheme(
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
                .scheme(
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
                .scheme(
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
            dependencies += module.dependencies
        }

        // Core Data
        let coreDataModels = module.coreDataModels

        let mainTarget = Target.target(
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

        var testTarget: Target?

        if module.hasUnitTest {
            // Resources
            var resources: ProjectDescription.ResourceFileElements?

            if module.hasUnitTestResources {
                resources = ["Targets/\(name)/Tests/Resources/**"]
            }

            // Dependencies
            let dependencies = [
                .target(name: appTargetName),
                .target(name: name)
            ] + module.unitTestDependencies

            testTarget = Target.target(
                name: "\(name)Tests",
                destinations: destinations,
                product: .unitTests,
                bundleId: "\(bundleId).\(name)Tests",
                deploymentTargets: deploymentTargets,
                infoPlist: .extendingDefault(with: infoPlist),
                sources: ["Targets/\(name)/Tests/**"],
                resources: resources,
                dependencies: dependencies,
                settings: .settings(
                    configurations: BuildEnvironment.getConfigurations(for: .unitTest)
                )
            )
        }

        var uiTestTarget: Target?

        if module.hasUITest {
            // Resources
            var resources: ProjectDescription.ResourceFileElements?

            if module.hasUITestResources {
                resources = ["Targets/\(name)/UITests/Resources/**"]
            }

            // Dependencies
            // Here the target will be the main app target.
            // Because UI test will run on the app itself.
            let dependencies = [
                .target(name: appTargetName)
            ] + module.uiTestDependencies

            uiTestTarget = Target.target(
                name: "\(name)UITests",
                destinations: destinations,
                product: .uiTests,
                bundleId: "\(bundleId).\(name)UITests",
                deploymentTargets: deploymentTargets,
                infoPlist: .extendingDefault(with: infoPlist),
                sources: ["Targets/\(name)/UITests/**"],
                resources: resources,
                dependencies: dependencies,
                settings: .settings(
                    configurations: BuildEnvironment.getConfigurations(for: .target)
                )
            )
        }

        return [mainTarget, testTarget, uiTestTarget].compactMap { $0 }
    }

    /// Helper function to create the application target and the unit test target.
    private static func makeAppTargets(
        name: String,
        config: AppModuleConfig,
        destinations: Destinations,
        deploymentTargets: DeploymentTargets,
        dependencies: [TargetDependency],
        infoPlist: [String: Plist.Value]
    ) -> [Target] {
        let mainTarget = Target.target(
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
            coreDataModels: config.coreDataModels
        )

        var testTarget: Target?

        if config.hasUnitTest {
            // Resources
            var resources: ProjectDescription.ResourceFileElements?

            if config.hasUnitTestResources {
                resources = ["Targets/\(name)/Tests/Resources/**"]
            }

            // Dependencies
            let dependencies = [
                .target(name: name)
            ] + config.unitTestDependencies

            testTarget = Target.target(
                name: "\(name)Tests",
                destinations: destinations,
                product: .unitTests,
                bundleId: "\(bundleId).\(name)Tests",
                deploymentTargets: deploymentTargets,
                infoPlist: .extendingDefault(with: infoPlist),
                sources: ["Targets/\(name)/Tests/**"],
                resources: resources,
                dependencies: dependencies,
                settings: .settings(
                    configurations: BuildEnvironment.getConfigurations(for: .unitTest)
                )
            )
        }

        var uiTestTarget: Target?

        if config.hasUITest {
            // Resources
            var resources: ProjectDescription.ResourceFileElements?

            if config.hasUITestResources {
                resources = ["Targets/\(name)/UITests/Resources/**"]
            }

            // Dependencies
            // Here the target will be the main app target.
            // Because UI test will run on the app itself.
            let dependencies = [
                .target(name: name)
            ] + config.uiTestDependencies

            let uiTestTarget = Target.target(
                name: "\(name)UITests",
                destinations: destinations,
                product: .uiTests,
                bundleId: "\(bundleId).\(name)UITests",
                deploymentTargets: deploymentTargets,
                infoPlist: .extendingDefault(with: infoPlist),
                sources: ["Targets/\(name)/UITests/**"],
                resources: resources,
                dependencies: dependencies,
                settings: .settings(
                    configurations: BuildEnvironment.getConfigurations(for: .target)
                )
            )
        }

        return [mainTarget, testTarget, uiTestTarget].compactMap { $0 }
    }
}
