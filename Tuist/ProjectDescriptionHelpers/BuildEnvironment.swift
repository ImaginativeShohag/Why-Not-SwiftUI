//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import ProjectDescription

public enum BuildSetting {
    case app, target, unitTest, notificationServiceExtension

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
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/Why-Not-SwiftUI.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Why-Not-SwiftUI",
                    "BUNDLE_LOADER": "$(TEST_HOST)",
                    "TEST_TARGET_NAME": "Why-Not-SwiftUI"
                ]
            
        case .notificationServiceExtension:
            [
                "PRODUCT_BUNDLE_IDENTIFIER": "\(Project.bundleId)\(buildTarget.bundleIdentifierPostFix).NotificationServiceExtension",
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG DEVELOPMENT"
            ]
        }
    }
}

// MARK: - Environment constants.

public enum BuildEnvironment: String, CaseIterable {
    case development, staging, production

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

    func conditions(variant: Configuration.Variant) -> SettingValue {
        switch self {
            case .development:
                "\(variant == .debug ? "DEBUG " : "")DEVELOPMENT"
            case .staging:
                "\(variant == .debug ? "DEBUG " : "")STAGING"
            case .production:
                "\(variant == .debug ? "DEBUG " : "")PRODUCTION"
        }
    }

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
