//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

public extension Bundle {
    /// A user-visible short name for the bundle.
    var appName: String { getInfo("CFBundleName") }

    /// The user-visible name for the bundle, used by Siri and visible on the iOS Home screen.
    var displayName: String { getInfo("CFBundleDisplayName") }

    /// The default language and region for the bundle, as a language ID.
    var language: String { getInfo("CFBundleDevelopmentRegion") }

    /// A unique identifier for a bundle.
    var identifier: String { getInfo("CFBundleIdentifier") }

    /// A human-readable copyright notice for the bundle.
    var copyright: String { getInfo("NSHumanReadableCopyright").replacingOccurrences(of: "\\\\n", with: "\n") }

    /// The version of the build that identifies an iteration of the bundle.
    var appBuild: String { getInfo("CFBundleVersion") }

    /// The release or version number of the bundle.
    var appVersionShort: String { getInfo("CFBundleShortVersionString") }

    /// Get single value from `Bundle.infoDictionary`. `Bundle.infoDictionary` is a dictionary, constructed from the bundle’s Info.plist file, that contains information about the receiver.
    ///
    /// - Returns: Converted `String` from `Bundle.infoDictionary` .
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "⚠️" }

    // MARK: - Decode json file

    /// Load and decode JSON file.
    ///
    /// - Returns: Decoded object of type `T`.
    func load<T: Codable>(_ file: String) -> T {
        // 1. Locate the json file
        guard let url = url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        // 2. Create a property for the data
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        // 3. Create a decoder
        let decoder = JSONDecoder()

        // 4. Create a property for the decoded data
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file) from bundle.")
        }

        // 5. Return the ready-to-use data
        return loaded
    }

    /// - Returns: `Data` from the resource `file`.
    ///
    /// Tested: `BundleLoadAsDataTest`
    func loadAsData(_ file: String) throws -> Data {
        // 1. Locate the json file
        guard let url = url(forResource: file, withExtension: nil) else {
            throw ResourceError.resourceNotFound(resource: file)
        }

        // 2. Create the data
        let data = try Data(contentsOf: url)

        return data
    }
}

enum ResourceError: Error, LocalizedError {
    case resourceNotFound(resource: String)

    var errorDescription: String {
        switch self {
        case .resourceNotFound(let resource):
            return "The resource '\(resource)' is not found."
        }
    }
}
