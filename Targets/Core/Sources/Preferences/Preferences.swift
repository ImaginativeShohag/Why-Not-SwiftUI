//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// This `enum` is contains the keys for the `Preferences`.
extension Key {
    static let authToken: Key = "authToken"
}

/// `Preferences` is a wrapper for `UserDefaults`.
///
/// Basic usages:
///
/// ```swift
/// let authToken = Preferences.authToken
/// ```
///
/// Observation example:
///
/// ```swift
/// var observation = Preferences.$authToken.observe { old, new in
///     print("Changed from: \(old) to \(new)")
/// }
/// ```
@MainActor
public enum Preferences {
    @UserDefault(key: .authToken)
    public static var authToken: String?

    // MARK: - Reset

    public static func reset() {
        // TODO: Try with `Mirror(reflection:)`.
        authToken = $authToken.defaultValue
    }
}
