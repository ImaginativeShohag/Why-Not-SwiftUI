//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class CategoriesViewModel {
    var state: UIState<[Category]> = .loading

    private var isPreview: Bool = false
    private nonisolated let repository: StoreRepository

    init(repository: StoreRepository = StoreRepository()) {
        self.repository = repository
    }

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

#if DEBUG

extension CategoriesViewModel {
    convenience init(
        forPreview: Bool,
        productsIsLoading: Bool,
        productsIsError: Bool
    ) {
        self.init()

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
