//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// This `enum` is contains the keys for the `Preferences`.
extension Key {
    static let authToken: Key = "authToken"

    static let codableExample: Key = "user"
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
public enum Preferences {
    @UserDefault(key: .authToken)
    public static var authToken: String?

    @CodableUserDefault(key: .codableExample)
    public static var codableExample: DummyCodable?

    // MARK: - Reset

    public static func reset() {
        // TODO: Try with `Mirror(reflection:)`.
        authToken = $authToken.defaultValue
        codableExample = $codableExample.defaultValue
    }
}
