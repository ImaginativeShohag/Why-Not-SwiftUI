//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

/// Control the app navigation.
///
/// Tested `NavControllerTests`
public class NavController: ObservableObject {
    public static let shared = NavController()

    /// Navigation stack.
    @Published public var navStack = [BaseDestination]()

    private init() {}

    /// Navigate to a destination.
    ///
    /// - Parameters:
    ///   - destination: target destination.
    ///   - launchSingleTop: Whether this navigation action should launch as single-top (i.e., there will be at most one copy of a given destination on the top of the back stack).
    public func navigateTo(_ destination: BaseDestination, launchSingleTop: Bool = false) {
        SuperLog.v("navigateTo: destination: \(destination) | launchSingleTop: \(launchSingleTop)")

        if destination is Destination.Root {
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
    public func navigateTo(_ destination: BaseDestination, launchSingleTop: Bool = false, popUpTo: BaseDestination.Type, inclusive: Bool = false) {
        SuperLog.v("navigateTo: destination: \(destination) | launchSingleTop: \(launchSingleTop) | popUpTo: \(popUpTo) | inclusive: \(inclusive)")

        if destination is Destination.Root {
            popUpToRoot()
        } else {
            self.popUpTo(popUpTo, inclusive: inclusive)

            navigateTo(destination, launchSingleTop: launchSingleTop)
        }
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
    public func popUpTo(_ destination: BaseDestination.Type, inclusive: Bool = false) {
        SuperLog.v("popUpTo: destination: \(destination) | inclusive: \(inclusive)")

        let destinationRoute = String(describing: destination)
        let rootDestinationRoute = String(describing: Destination.Root.self)
        SuperLog.v("popUpTo: destinationRoute: \(destinationRoute) == rootDestinationRoute: \(rootDestinationRoute)")

        if destinationRoute == rootDestinationRoute {
            popUpToRoot()
        } else if !navStack.isEmpty {
            let index = navStack.lastIndex { currentDestination in
                let currentDestinationRoute = String(describing: type(of: currentDestination))
                SuperLog.v("popUpTo: destinationRoute: \(destinationRoute) == currentDestinationRoute: \(currentDestinationRoute)")

                return destinationRoute == currentDestinationRoute
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
