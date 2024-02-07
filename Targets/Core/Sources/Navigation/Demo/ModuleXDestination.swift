//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

#if DEBUG

class ModuleXDestination: BaseDestination {}

extension Destination {
    final class A: ModuleXDestination {}

    final class B: ModuleXDestination {}
}

extension ModuleXDestination {
    @ViewBuilder
    static func getScreen(for destination: ModuleXDestination) -> some View {
        switch destination {
        case is Destination.A:
            NavigationDemoScreen(destination.route)

        case is Destination.B:
            NavigationDemoScreen(destination.route)

        default:
            EmptyView()
        }
    }
}

#endif
