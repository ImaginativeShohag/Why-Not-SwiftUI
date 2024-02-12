//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

/// # Decision Documentation:
///
/// - `NavigationPath` ❌
///     - Pros:
///         - We can use any type of data.
///     - Cons:
///         - We cannot traverse through the stack, so we can't implement `popUpTo` etc. with this.
///
/// - `enum` as Destination ❌
///     - Pros:
///         - Minimal code needed to use.
///     - Cons:
///         - Tight coupling issue. Have to add all destination to one `enum`.
///         - We have to give default blank values for `popUpTo`.
///
/// - `BaseDestination` `Class` ✅
///     - Pros:
///         - It is decoupled way. Every module can have there separate navigation destination objects.
///         - We can safely pass values and no need default blank values.
///     - Cons:
///         - Extra line of code.
///
/// # Features
///
/// - ✅ Pass parameters on navigation with type safety
/// - ✅ Pop up to a destination directly or on navigate
/// - ✅ Concise code
/// - ❌ Navigate to multiple destination at once

open class BaseDestination {
    public var route: String {
        String(describing: type(of: self))
    }

    public init() {}

    @ViewBuilder
    open func getScreen() -> any View {
        fatalError("Not implemented!")
    }
}
