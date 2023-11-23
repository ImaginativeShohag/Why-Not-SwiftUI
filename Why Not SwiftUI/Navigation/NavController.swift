//
//  Copyright © 2023 Apple Inc. All rights reserved.
//

import Foundation

/// Control the app navigation.
///
/// Tested `NavControllerTests`
class NavController: ObservableObject {
    static let shared = NavController()

    /// Navigation stack.
    @Published var navStack = [Destination]()

    private init() {}

    /// Navigate to a destination.
    ///
    /// - Parameters:
    ///   - destination: target destination.
    ///   - launchSingleTop: Whether this navigation action should launch as single-top (i.e., there will be at most one copy of a given destination on the top of the back stack).
    func navigateTo(_ destination: Destination, launchSingleTop: Bool = false) {
        CoolLog.v("navigateTo: destination: \(destination) | launchSingleTop: \(launchSingleTop)")

        if destination == .root {
            popUpToRoot()
        } else if !navStack.isEmpty, launchSingleTop {
            if navStack.last != destination {
                navStack.append(destination)
            }
        } else {
            navStack.append(destination)
        }
    }

    /// Navigate to a destination.
    ///
    /// - Parameters:
    ///   - destination: Target destination.
    ///   - launchSingleTop: Whether this navigation action should launch as single-top (i.e., there will be at most one copy of a given destination on the top of the back stack).
    ///   - popUpTo: Pop up to a given destination.
    ///   - inclusive: Whether the `popUpTo` destination should be popped from the back stack.
    ///
    /// - Note: If `Destination.root` is passed for `destination`, then other parameters will be ignored.
    func navigateTo(_ destination: Destination, launchSingleTop: Bool = false, popUpTo: Destination, inclusive: Bool = false) {
        CoolLog.v("navigateTo: destination: \(destination) | launchSingleTop: \(launchSingleTop) | popUpTo: \(popUpTo) | inclusive: \(inclusive)")

        if destination == .root {
            popUpToRoot()
        } else {
            self.popUpTo(popUpTo, inclusive: inclusive)

            navigateTo(destination, launchSingleTop: launchSingleTop)
        }
    }

    /// Attempts to pop the navigation stack's back stack. Analogous to when the user presses the back button.
    func popBackStack() {
        CoolLog.v("popBackStack")

        if !navStack.isEmpty {
            navStack.removeLast()
        }
    }

    /// Pop up to a given destination. This pops all non-matching destinations from the back stack until this destination is found.
    ///
    /// - Parameters:
    ///   - destination: Target destination.
    ///   - inclusive: Whether the `destination` should be popped from the back stack.
    func popUpTo(_ destination: Destination, inclusive: Bool = false) {
        CoolLog.v("popUpTo: destination: \(destination) | inclusive: \(inclusive)")

        if destination == .root {
            popUpToRoot()
        } else if !navStack.isEmpty {
            let index = navStack.lastIndex(of: destination)

            if let index = index {
                var removeItemCount = navStack.count - index

                if !inclusive {
                    removeItemCount = removeItemCount - 1
                }

                navStack.removeLast(removeItemCount)
            }
        }
    }

    func popUpToRoot() {
        navStack.removeAll()
    }

    func currentDestination() -> Destination {
        return navStack.last ?? .root
    }

    /// - Returns: Current navigation stack as `String`.
    func description() -> String {
        var path = ""

        for (index, item) in navStack.enumerated() {
            path += "\(index == 0 ? "" : " > ")(\(index + 1)) \(item)"
        }

        return path
    }
}
