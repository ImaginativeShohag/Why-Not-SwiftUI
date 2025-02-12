//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

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
    static var user: StoreUser?
    
    @CodableUserDefault(key: .name)
    static var name: String?
    
    @CodableUserDefault(key: .phoneNumber)
    static var phoneNumber: String?
    
    @CodableUserDefault(key: .address)
    static var address: String?

    // MARK: - Reset

    static func reset() {
        // TODO: Try with `Mirror(reflection:)`.
        user = $user.defaultValue
        name = $name.defaultValue
        phoneNumber = $phoneNumber.defaultValue
        address = $address.defaultValue
    }
}
