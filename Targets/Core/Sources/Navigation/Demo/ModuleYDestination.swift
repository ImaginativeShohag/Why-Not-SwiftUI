//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

#if DEBUG

class ModuleYDestination: BaseDestination {}

extension Destination {
    final class C: ModuleYDestination {
        let id: Int

        public init(id: Int) {
            self.id = id
        }
    }
}

extension ModuleYDestination {
    @ViewBuilder
    static func getScreen(for destination: ModuleYDestination) -> some View {
        switch destination {
        case is Destination.C:
            let currentDestination = destination as! Destination.C

            NavigationDemoScreen("\(destination.route) (\(currentDestination.id))")

        default:
            EmptyView()
        }
    }
}

#endif
