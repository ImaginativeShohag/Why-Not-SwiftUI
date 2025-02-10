//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class ProductsViewModel: ProductProcessActions {
    let categoryId: String
    var productsState: UIState<[UIStore.Product]> = .loading

    private var isPreview: Bool = false
    private nonisolated let repository: StoreRepository

    init(
        categoryId: String,
        repository: StoreRepository = StoreRepository(),
        cartManager: CartManager = CartManager.shared
    ) {
        self.repository = repository
        self.categoryId = categoryId

        super.init(cartManager: cartManager)
    }

    func loadProducts(forced: Bool = false) async {
        guard !isPreview, productsState.isLoading || forced else { return }

        productsState = .loading

        let result = await repository.getCategoryProducts(
            categoryId: categoryId
        )

        switch result {
        case .success(let productList):
            let finalProducts = await processProducts(productList)
            productsState = .data(data: finalProducts)

        case .failure(_, let errorMessage, _):
            productsState = .error(message: errorMessage)
        }
    }
}

#if DEBUG

extension ProductsViewModel {
    convenience init(
        forPreview: Bool,
        productsIsLoading: Bool,
        productsIsError: Bool
    ) {
        self.init(categoryId: "XYZ")

        isPreview = true

        if productsIsLoading {
            productsState = .loading
        } else if productsIsError {
            productsState = .error(message: "Something went wrong! Try again.")
        } else {
            productsState = .data(data: UIStore.Product.mockItems())
        }
    }
}

#endif
