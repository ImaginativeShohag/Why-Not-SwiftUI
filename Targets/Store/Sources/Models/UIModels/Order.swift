//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

extension UIStore {
    struct Order: Identifiable {
        let id: Int
        let orderedAt: Date?
        let products: [Product]
    }
}

#if DEBUG

extension UIStore.Order {
    @MainActor
    static func mockItems() -> [UIStore.Order] {
        var items: [UIStore.Order] = []

        for index in 1 ... 10 {
            items.append(
                UIStore.Order(
                    id: index,
                    orderedAt: index % 2 == 0 ? nil : Date(),
                    products: UIStore.Product.mockItems().map {
                        $0.quantity = Int.random(in: 1 ... 5)
                        return $0
                    }
                )
            )
        }

        return items
    }
}

#endif
