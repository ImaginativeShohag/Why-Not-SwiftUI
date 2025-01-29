//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

typealias Category = String
typealias CategoryListResponse = [Category]

#if DEBUG

extension Category {
    static func mockItems() -> [Category] {
        return ["Electronics", "Clothing", "Books", "Home & Kitchen", "Sports"]
    }
}

#endif
