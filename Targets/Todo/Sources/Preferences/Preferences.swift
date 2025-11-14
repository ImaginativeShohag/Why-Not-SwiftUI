//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

/// This `enum` is contains the keys for the `Preferences`.
extension Key {
    static let showCompletedItems: Key = "showCompletedItems"
    static let sortToShowLatestFirst: Key = "sortToShowLatestFirst"
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
    @UserDefault(key: .showCompletedItems)
    static var showCompletedItems: Bool?
    
    @UserDefault(key: .sortToShowLatestFirst)
    static var sortToShowLatestFirst: Bool?

    // MARK: - Reset

    static func reset() {
        // TODO: Try with `Mirror(reflection:)`.
        showCompletedItems = $showCompletedItems.defaultValue
        sortToShowLatestFirst = $sortToShowLatestFirst.defaultValue
    }
}
