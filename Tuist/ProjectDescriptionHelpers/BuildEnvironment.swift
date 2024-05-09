//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription

public enum BuildSetting {
    case app, target, unitTest, notificationServiceExtension

    /// - Returns: The build settings for the schemas based on the `buildTarget` and `variant`.
    func settings(buildTarget: BuildEnvironment, variant: Configuration.Variant) -> SettingsDictionary {
        switch self {
            case .app:
                [
                    "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)\(buildTarget.bundleIdentifierPostFix)",
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": buildTarget.conditions(variant: variant)
                ]

            case .target:
                [
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": buildTarget.conditions(variant: variant)
                ]

            case .unitTest:
                [
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": buildTarget.conditions(variant: variant),

                    // For Testing
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/\(Constants.projectName).app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/\(Constants.projectName)",
                    "BUNDLE_LOADER": "$(TEST_HOST)",
                    "TEST_TARGET_NAME": "\(Constants.projectName)"
                ]

            case .notificationServiceExtension:
                [
                    "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)\(buildTarget.bundleIdentifierPostFix).NotificationServiceExtension",
                    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": buildTarget.conditions(variant: variant)
                ]
        }
    }
}

// MARK: - Environment constants.

public enum BuildEnvironment: String, CaseIterable {
    case development, staging, production

    /// - Returns: The name of the schemas based on the `variant`.
    func name(variant: Configuration.Variant) -> ConfigurationName {
        switch self {
            case .development:
                ConfigurationName(stringLiteral: "\(variant == .debug ? "Debug" : "Release") Development")
            case .staging:
                ConfigurationName(stringLiteral: "\(variant == .debug ? "Debug" : "Release") Staging")
            case .production:
                ConfigurationName(stringLiteral: "\(variant == .debug ? "Debug" : "Release") Production")
        }
    }

    /// - Returns: The  Active Compilation Conditions based on `variant`.
    func conditions(variant: Configuration.Variant) -> SettingValue {
        switch self {
            case .development:
                "$(inherited) \(variant == .debug ? "DEBUG " : "")DEVELOPMENT"
            case .staging:
                "$(inherited) \(variant == .debug ? "DEBUG " : "")STAGING"
            case .production:
                "$(inherited) \(variant == .debug ? "DEBUG " : "")PRODUCTION"
        }
    }

    /// - Returns: The post-fix for the bundle identifier.
    var bundleIdentifierPostFix: String {
        switch self {
            case .development:
                "-dev"
            case .staging:
                "-staging"
            case .production:
                ""
        }
    }

    /// - Returns: The `xcconfig` files directory path.
    var xcconfigFilePath: Path {
        switch self {
            case .development:
                "ConfigurationFiles/Development.xcconfig"
            case .staging:
                "ConfigurationFiles/Staging.xcconfig"
            case .production:
                "ConfigurationFiles/Production.xcconfig"
        }
    }

    /// - Returns: The build configurations based on the `instance`.
    public static func getConfigurations(for instance: BuildSetting) -> [Configuration] {
        var configurations: [Configuration] = []

        for item in BuildEnvironment.allCases {
            // Debug
            configurations.append(
                .debug(
                    name: item.name(variant: .debug),
                    settings: instance.settings(buildTarget: item, variant: .debug),
                    xcconfig: item.xcconfigFilePath
                )
            )

            // Release
            configurations.append(
                .release(
                    name: item.name(variant: .release),
                    settings: instance.settings(buildTarget: item, variant: .release),
                    xcconfig: item.xcconfigFilePath
                )
            )
        }

        return configurations
    }
}
