//
//  Copyright © 2023 Apple Inc. All rights reserved.
//

import Foundation

extension Destination: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.description)
    }
}

extension Destination: Equatable {
    public static func == (lhs: Destination, rhs: Destination) -> Bool {
        return lhs.description == rhs.description
    }
}
