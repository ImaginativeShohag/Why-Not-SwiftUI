//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class HomeViewModel {
    var productsState: UIState<[Product]> = .loading
    var categoriesState: UIState<[Category]> = .loading

    private var isPreview: Bool = false

    nonisolated private let repository: StoreRepository

    init(repository: StoreRepository = StoreRepository()) {
        self.repository = repository
    }

    func loadCategories(forced: Bool = false) async {
        guard !isPreview, categoriesState.isLoading || forced else { return }

        categoriesState = .loading

        let result = await repository.getCategories()

        switch result {
        case .success(let categoryList):
            categoriesState = .data(data: categoryList)

        case .failure(_, let errorMessage, _):
            categoriesState = .error(message: errorMessage)
        }
    }

    func loadProducts(forced: Bool = false) async {
        guard !isPreview, productsState.isLoading || forced else { return }

        productsState = .loading

        let result = await repository.getProducts()

        switch result {
        case .success(let productList):
            productsState = .data(data: productList)

        case .failure(_, let errorMessage, _):
            productsState = .error(message: errorMessage)
        }
    }
}

#if DEBUG

extension HomeViewModel {
    convenience init(
        forPreview: Bool,
        productsIsLoading: Bool,
        productsIsError: Bool,
        categoriesIsLoading: Bool,
        categoriesIsError: Bool
    ) {
        self.init()

        isPreview = true

        if productsIsLoading {
            productsState = .loading
        } else if productsIsError {
            productsState = .error(message: "Something went wrong! Try again.")
        } else {
            productsState = .data(data: Product.mockItems())
        }
        
        if categoriesIsLoading {
            categoriesState = .loading
        } else if categoriesIsError {
            categoriesState = .error(message: "Something went wrong! Try again.")
        } else {
            categoriesState = .data(data: Category.mockItems())
        }
        
    }
}

#endif
