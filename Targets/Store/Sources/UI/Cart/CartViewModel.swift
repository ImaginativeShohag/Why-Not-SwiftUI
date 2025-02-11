//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class CartViewModel: CartActions {
    var orderSubmitState: UIState<Bool>?

    private var isPreview: Bool = false
    private nonisolated let repository: StoreRepository

    init(
        repository: StoreRepository = StoreRepository(),
        cartManager: CartManager = CartManager.shared
    ) {
        self.repository = repository

        super.init(cartManager: cartManager)
    }

    func submitOrder() async {
        guard !isPreview else { return }

        orderSubmitState = .loading

        try? await Task.sleep(for: .seconds(2))

        clearCart()

        orderSubmitState = .data(data: true)
    }
}

#if DEBUG

extension CartViewModel {
    convenience init(
        forPreview: Bool,
        productIsEmpty: Bool,
        productsIsLoading: Bool,
        productsIsError: Bool
    ) {
        if productIsEmpty {
            self.init(
                cartManager: CartManager.mockWithEmptyItem
            )
        } else {
            self.init(
                cartManager: CartManager.mock
            )
        }

        isPreview = true

        if productsIsLoading {
            orderSubmitState = .loading
        } else if productsIsError {
            orderSubmitState = .error(message: "Something went wrong! Try again.")
        } else {
            orderSubmitState = .data(data: true)
        }
    }
}

#endif
