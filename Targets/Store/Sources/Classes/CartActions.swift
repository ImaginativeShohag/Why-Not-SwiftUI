//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@MainActor
class CartActions {
    let cartManager: CartManager

    init(cartManager: CartManager) {
        self.cartManager = cartManager
    }

    func increaseQuantity(for product: UIStore.Product) {
        cartManager.increaseQuantity(for: product)
    }

    func decreaseQuantity(for product: UIStore.Product) {
        cartManager.decreaseQuantity(for: product)
    }

    func clearCart() {
        cartManager.clearCart()
    }

    func totalPrice() -> Double {
        return cartManager.totalPrice()
    }
}
