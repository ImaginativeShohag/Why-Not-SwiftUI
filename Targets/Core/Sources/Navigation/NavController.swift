//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

/// # Decision Documentation:
///
/// - `NavigationPath` as Navigation Stack❌
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
///         - It is decoupled way. Every module/screen can have there separate navigation destination objects.
///         - We can safely pass values and no need default blank values.
///     - Cons:
///         - Extra line of code.
///
/// # Features
///
/// - ✅ Pass parameters on navigation with type safety
/// - ✅ Pop up to a destination directly or on navigate
/// - ✅ Concise code
/// - ✅ Navigate to multiple destination at once

/// Control the app navigation.
///
/// Tested `NavControllerTests`
@MainActor
@Observable
public final class NavController {
    public static let shared = NavController()

    /// Navigation stack.
    public var navStack = [BaseDestination]()

    private init() {}

    /// Navigate to a destination.
    ///
    /// - Parameters:
    ///   - destination: target destination.
    ///   - launchSingleTop: Whether this navigation action should launch as single-top (i.e., there will be at most one copy of a given destination on the top of the back stack).
    ///
    /// - Note: Don't pass `Destination.Root`in `destination` parameter.
    public func navigateTo(_ destination: BaseDestination, launchSingleTop: Bool = false) {
        SuperLog.v("navigateTo: destination: \(destination) | launchSingleTop: \(launchSingleTop)")

        guard !(destination is Destination.Root) else {
            fatalError("This is not allowed. To go back to root screen, use `popUpToRoot()` instead.")
        }

        if !navStack.isEmpty, launchSingleTop {
            if navStack.last != destination {
                navStack.append(destination)
            }
        } else {
            navStack.append(destination)
        }
    }

    /// Navigate to multiple destinations.
    ///
    /// - Parameters:
    ///   - destinations: target destinations.
    ///
    /// - Note: Don't pass `Destination.Root`in `destination` parameter.
    public func navigateTo(_ destinations: [BaseDestination]) {
        SuperLog.v("navigateTo: destinations: \(destinations)")

        guard destinations.first(where: { $0 is Destination.Root }) == nil else {
            fatalError("This is not allowed. To go back to root screen, use `popUpToRoot()` instead.")
        }

        for destination in destinations {
            navStack.append(destination)
        }
    }

    /// Navigate to multiple destinations.
    ///
    /// - Parameters:
    ///   - destinations: target destinations.
    ///   - popUpTo: Pop up to a given destination.
    ///   - inclusive: Whether the `popUpTo` destination should be popped from the back stack.
    ///
    /// - Note: Don't pass `Destination.Root`in `destination` or `popUpTo` parameter.
    public func navigateTo(_ destinations: [BaseDestination], popUpTo: BaseDestination.Type, inclusive: Bool = false) {
        SuperLog.v("navigateTo: destinations: \(destinations) | popUpTo: \(popUpTo) | inclusive: \(inclusive)")

        guard destinations.first(where: { $0 is Destination.Root }) == nil else {
            fatalError("This is not allowed. To go back to root screen, use `popUpToRoot()` instead.")
        }

        self.popUpTo(popUpTo, inclusive: inclusive)

        navigateTo(destinations)
    }

    /// Navigate to a destination.
    ///
    /// - Parameters:
    ///   - destination: Target destination.
    ///   - launchSingleTop: Whether this navigation action should launch as single-top (i.e., there will be at most one copy of a given destination on the top of the back stack).
    ///   - popUpTo: Pop up to a given destination.
    ///   - inclusive: Whether the `popUpTo` destination should be popped from the back stack.
    ///
    /// - Note: Don't pass `Destination.Root`in `destination` or `popUpTo` parameter.
    public func navigateTo(_ destination: BaseDestination, launchSingleTop: Bool = false, popUpTo: BaseDestination.Type, inclusive: Bool = false) {
        SuperLog.v("navigateTo: destination: \(destination) | launchSingleTop: \(launchSingleTop) | popUpTo: \(popUpTo) | inclusive: \(inclusive)")

        guard !(destination is Destination.Root) else {
            fatalError("This is not allowed. To go back to root screen, use `popUpToRoot()` instead.")
        }

        self.popUpTo(popUpTo, inclusive: inclusive)

        navigateTo(destination, launchSingleTop: launchSingleTop)
    }

    /// Attempts to pop the navigation stack's back stack. Analogous to when the user presses the back button.
    public func popBackStack() {
        SuperLog.v("popBackStack")

        if !navStack.isEmpty {
            navStack.removeLast()
        }
    }

    /// Pop up to a given destination. This pops all non-matching destinations from the back stack until this destination is found.
    ///
    /// - Parameters:
    ///   - destination: Target destination.
    ///   - inclusive: Whether the `destination` should be popped from the back stack.
    ///
    /// - Note: Don't pass `Destination.Root`in `destination` parameter.
    public func popUpTo(_ destination: BaseDestination.Type, inclusive: Bool = false) {
        SuperLog.v("popUpTo: destination: \(destination) | inclusive: \(inclusive)")

        guard !(destination is Destination.Root.Type) else {
            fatalError("This is not allowed. To go back to root screen, use `popUpToRoot()` instead.")
        }

        if !navStack.isEmpty {
            let destinationRoute = String(describing: destination)

            let index = navStack.lastIndex { currentDestination in
                SuperLog.v("popUpTo: destinationRoute: \(destinationRoute) == currentDestination.route: \(currentDestination.route)")

                return destinationRoute == currentDestination.route
            }

            if let index = index {
                var removeItemCount = navStack.count - index

                if !inclusive {
                    removeItemCount = removeItemCount - 1
                }

                navStack.removeLast(removeItemCount)
            }
        }
    }

    public func popUpToRoot() {
        navStack.removeAll()
    }

    public func currentDestination() -> BaseDestination {
        return navStack.last ?? Destination.Root()
    }

    /// - Returns: Current navigation stack as `String`.
    public func description() -> String {
        var path = ""

        for (index, item) in navStack.enumerated() {
            path += "\(index == 0 ? "" : " > ")(\(index + 1)) \(type(of: item))"
        }

        return path
    }
}
