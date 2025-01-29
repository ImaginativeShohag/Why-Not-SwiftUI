//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class ProductsViewModel {
    let categoryId: String
    var productsState: UIState<[Product]> = .loading

    private var isPreview: Bool = false
    nonisolated private let repository: StoreRepository

    init(categoryId: String, repository: StoreRepository = StoreRepository()) {
        self.repository = repository
        self.categoryId = categoryId
    }

    func loadProducts(forced: Bool = false) async {
        guard !isPreview, productsState.isLoading || forced else { return }

        productsState = .loading

        let result = await repository.getCategoryProducts(
            categoryId: categoryId
        )

        switch result {
        case .success(let productList):
            productsState = .data(data: productList)

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
            productsState = .data(data: Product.mockItems())
        }
    }
}

#endif
