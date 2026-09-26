//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import NetworkKit

/// This `enum` is contains the keys for the `Preferences`.
extension Key {
    static let user: Key = "user"
    static let name: Key = "name"
    static let phoneNumber: Key = "phoneNumber"
    static let address: Key = "address"
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
    private static var _user: StoreUser?

    /// Returns the stored user, or mock user from environment when running in UI test mode
    static var user: StoreUser? {
        get {
            #if DEBUG
            if isUITestEnvironment {
                // Check if user data was passed through launch environment
                if let userJSON = ProcessInfo.processInfo.environment[uiTestEnvKeyUserData],
                   let jsonData = userJSON.data(using: .utf8),
                   let user = try? JSONDecoder().decode(StoreUser.self, from: jsonData) {
                    return user
                }
            }
            #endif
            return _user
        }
        set {
            _user = newValue
        }
    }

    @UserDefault(key: .name)
    static var name: String?

    @UserDefault(key: .phoneNumber)
    static var phoneNumber: String?

    @UserDefault(key: .address)
    static var address: String?

    // MARK: - Reset

    static func reset() {
        // TODO: Try with `Mirror(reflection:)`.
        _user = $_user.defaultValue
        name = $name.defaultValue
        phoneNumber = $phoneNumber.defaultValue
        address = $address.defaultValue
    }
}
