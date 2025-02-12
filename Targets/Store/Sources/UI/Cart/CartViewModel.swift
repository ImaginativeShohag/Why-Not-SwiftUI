//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class CartViewModel: CartActions {
    private var isPreview: Bool = false
    private nonisolated let repository: StoreRepository

    init(
        repository: StoreRepository = StoreRepository(),
        cartManager: CartManager = CartManager.shared
    ) {
        self.repository = repository

        super.init(cartManager: cartManager)
    }
}

#if DEBUG

extension CartViewModel {
    convenience init(
        forPreview: Bool,
        productIsEmpty: Bool
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
    }
}

#endif
