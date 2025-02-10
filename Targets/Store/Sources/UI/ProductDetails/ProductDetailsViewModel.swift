//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class ProductDetailsViewModel: ProductProcessActions {
    let productId: Int
    var productState: UIState<UIStore.Product> = .loading

    private var isPreview: Bool = false
    private nonisolated let repository: StoreRepository

    init(
        productId: Int,
        repository: StoreRepository = StoreRepository(),
        cartManager: CartManager = CartManager.shared
    ) {
        self.repository = repository
        self.productId = productId

        super.init(cartManager: cartManager)
    }

    func loadProduct(forced: Bool = false) async {
        guard !isPreview, productState.isLoading || forced else { return }

        productState = .loading

        let result = await repository.getProductDetails(
            productId: productId
        )

        switch result {
        case .success(let product):
            let finalProduct = await processProduct(product)
            productState = .data(data: finalProduct)

        case .failure(_, let errorMessage, _):
            productState = .error(message: errorMessage)
        }
    }
}

#if DEBUG

extension ProductDetailsViewModel {
    convenience init(
        forPreview: Bool,
        productsIsLoading: Bool,
        productsIsError: Bool
    ) {
        self.init(
            productId: 0,
            cartManager: CartManager.mock
        )

        isPreview = true

        if productsIsLoading {
            productState = .loading
        } else if productsIsError {
            productState = .error(message: "Something went wrong! Try again.")
        } else {
            productState = .data(data: UIStore.Product.mockItems().first!)
        }
    }
}

#endif
