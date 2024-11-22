//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

extension BaseDestination: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.route)
    }
}

extension BaseDestination: Equatable {
    public static func == (lhs: BaseDestination, rhs: BaseDestination) -> Bool {
        return lhs.route == rhs.route
    }
}
