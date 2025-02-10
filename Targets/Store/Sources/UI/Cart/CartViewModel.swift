//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class CartViewModel: CartActions {
    var state: UIState<[Category]> = .loading

    private var isPreview: Bool = false
    private nonisolated let repository: StoreRepository

    init(
        repository: StoreRepository = StoreRepository(),
        cartManager: CartManager = CartManager.shared
    ) {
        self.repository = repository

        super.init(cartManager: cartManager)
    }

    
    #warning("remove this")
    
    func loadProducts(forced: Bool = false) async {
        guard !isPreview, state.isLoading || forced else { return }

        state = .loading

        let result = await repository.getCategories()

        switch result {
        case .success(let categories):
            state = .data(data: categories)

        case .failure(_, let errorMessage, _):
            state = .error(message: errorMessage)
        }
    }
}

#warning("Convert this to UseCase")
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

    func totalPrice() -> Double {
        return cartManager.totalPrice()
    }
}

#if DEBUG

extension CartViewModel {
    convenience init(
        forPreview: Bool,
        productsIsLoading: Bool,
        productsIsError: Bool
    ) {
        self.init(
            cartManager: CartManager.mock
        )

        isPreview = true

        if productsIsLoading {
            state = .loading
        } else if productsIsError {
            state = .error(message: "Something went wrong! Try again.")
        } else {
            state = .data(data: Category.mockItems())
        }
    }
}

#endif
