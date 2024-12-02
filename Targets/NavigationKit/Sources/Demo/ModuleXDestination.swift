//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

#if DEBUG

extension Destination {
    final class A: BaseDestination {
        override func getScreen() -> any View {
            NavigationDemoScreen(route)
        }
    }

    final class B: BaseDestination {
        override func getScreen() -> any View {
            NavigationDemoScreen(route)
        }
    }
}

#endif
