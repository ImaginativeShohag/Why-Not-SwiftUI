//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

/// This `enum` is contains the keys for the `Preferences`.
extension Key {
    static let user: Key = "user"
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
extension Preferences {
    @CodableUserDefault(key: .user)
    static var user: StoreUser?

    // MARK: - Reset

    static func reset() {
        // TODO: Try with `Mirror(reflection:)`.
        user = $user.defaultValue
    }
}
