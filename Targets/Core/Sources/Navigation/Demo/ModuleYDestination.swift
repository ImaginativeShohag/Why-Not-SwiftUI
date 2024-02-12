//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

#if DEBUG

extension BaseDestination {
    final class C: BaseDestination {
        let id: Int

        public init(id: Int) {
            self.id = id
        }

        override func getScreen() -> any View {
            NavigationDemoScreen("\(route) (\(id))")
        }
    }
}

#endif
