//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

@MainActor
@Observable
class CartManager {
    static let shared = CartManager()

    private init() {}

    private(set) var items: Set<UIStore.Product> = []

    func increaseQuantity(for product: UIStore.Product) {
        let existingProduct = items.first(where: { $0.id == product.id }) ?? product

        existingProduct.increaseQuantity()

        // Add to cart
        items.insert(existingProduct)
    }

    func decreaseQuantity(for product: UIStore.Product) {
        let existingProduct = items.first(where: { $0.id == product.id }) ?? product

        existingProduct.decreaseQuantity()

        // Remove the cart if the count not greater than zero.
        if existingProduct.quantity <= 0 {
            items.remove(existingProduct)
        }
    }

    func clearCart() {
        // Reset quantity
        for item in items {
            item.quantity = 0
        }

        // Remove all items
        items.removeAll()
    }

    func totalPrice() -> Double {
        items.reduce(0) { result, product in
            result + Double(product.price) * Double(product.quantity)
        }
    }
}

#if DEBUG

extension CartManager {
    static let mock: CartManager = {
        let manager = CartManager()

        for item in UIStore.Product.mockItems() {
            for _ in 0 ..< Int.random(in: 1 ... 10) {
                manager.increaseQuantity(for: item)
            }
        }

        return manager
    }()

    static let mockWithEmptyItem: CartManager = .init()
}

#endif
