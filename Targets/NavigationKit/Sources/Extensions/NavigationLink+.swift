//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension NavigationLink where Destination == Never {
    /// Creates a navigation link that presents the view corresponding to a destination.
    ///
    /// - Note: This is a wrapper for the ``init(value:label:)`` initializer to add support for ``BaseDestination``. The existing initializer is not working directly. We have to manually cast the destination with ``BaseDestination``. This initializer solves the issue.
    ///
    /// - Parameters:
    ///   - destination: An destination to present.
    ///     When the user selects the link, SwiftUI stores a copy of the destination.
    ///   - label: A label that describes the view that this link presents.
    init(destination: BaseDestination, @ViewBuilder label: () -> Label) {
        self.init(value: destination, label: label)
    }
}
