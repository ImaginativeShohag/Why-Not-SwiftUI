//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

/// # Decision Documentation:
///
/// - `NavigationPath`
///     - Pros:
///         - We can use any type of data.
///     - Cons:
///         - We cannot traverse through the stack, so we can't implement `popUpTo` etc with this.
///
/// - `enum` as Destination
///     - Pros:
///         - Minimal code needed to use.
///     - Cons:
///         - Tight coupling issue. Have to add all destination to one `enum`.
///         - We have to give default blank values for `popUpTo`.
///
/// - `BaseDestination` `Class`
///     - Pros:
///         - It is decoupled. Every module can have there separate navigation destination objects.
///         - We can safely pass values and no need default blank values.
///     - Cons:
///         - Extra line of code.
///
/// # Targets
///
/// - ✅ Pass parameters
/// - ✅ Pop-up-to: somehow use route/destination without the params
/// - ✅ Less code
/// - ✅ We can't use string as route, because we want to pass parameter safely, who can we pass safely?
/// - ❌ Can we use property wrapper for this? Like @Route("destination_name")

open class BaseDestination {
    public var route: String {
        String(describing: type(of: self))
    }

    public init() {}
}

public enum Destination {}

// MARK: - Default Root Destination

public extension Destination {
    final class Root: BaseDestination {}
}
