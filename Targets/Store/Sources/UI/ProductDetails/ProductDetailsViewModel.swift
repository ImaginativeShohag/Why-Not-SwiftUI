//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class ProductDetailsViewModel {
    let productId: Int
    var productState: UIState<Product> = .loading

    private var isPreview: Bool = false
    nonisolated private let repository: StoreRepository

    init(productId: Int, repository: StoreRepository = StoreRepository()) {
        self.repository = repository
        self.productId = productId
    }

    func loadProduct(forced: Bool = false) async {
        guard !isPreview, productState.isLoading || forced else { return }

        productState = .loading

        let result = await repository.getProductDetails(
            productId: productId
        )

        switch result {
        case .success(let product):
            productState = .data(data: product)

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
        self.init(productId: 0)

        isPreview = true

        if productsIsLoading {
            productState = .loading
        } else if productsIsError {
            productState = .error(message: "Something went wrong! Try again.")
        } else {
            productState = .data(data: Product.mockItems().first!)
        }
    }
}

#endif
