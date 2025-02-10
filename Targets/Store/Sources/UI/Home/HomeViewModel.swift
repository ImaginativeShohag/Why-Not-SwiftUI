//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class HomeViewModel: ProductProcessActions {
    var productsState: UIState<[UIStore.Product]> = .loading
    var categoriesState: UIState<[Category]> = .loading
    var user: StoreUser?

    private var isPreview: Bool = false

    private nonisolated let repository: StoreRepository

    init(
        repository: StoreRepository = StoreRepository(),
        cartManager: CartManager = CartManager.shared
    ) {
        self.repository = repository

        super.init(cartManager: cartManager)

        initialize()
    }

    private func initialize() {
        guard !isPreview else { return }

        user = Preferences.user
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
            let finalProducts = await processProducts(productList)
            productsState = .data(data: finalProducts)

        case .failure(_, let errorMessage, _):
            productsState = .error(message: errorMessage)
        }
    }
}

class ProductProcessActions: CartActions {
    func processProducts(_ products: [Product]) async -> [UIStore.Product] {
        var finalProducts = [UIStore.Product]()

        for product in products {
            await finalProducts.append(
                processProduct(product)
            )
        }

        return finalProducts
    }

    func processProduct(_ product: Product) async -> UIStore.Product {
        let cacheUiProduct = await ProductCache.shared.getProduct(product.id)
        if let cacheUiProduct {
            return cacheUiProduct
        } else {
            let uiModel = product.toUIModel()
            await ProductCache.shared.updateProduct(uiModel)
            return uiModel
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

        user = StoreUser.mockItem()

        if productsIsLoading {
            productsState = .loading
        } else if productsIsError {
            productsState = .error(message: "Something went wrong! Try again.")
        } else {
            productsState = .data(data: UIStore.Product.mockItems())
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
