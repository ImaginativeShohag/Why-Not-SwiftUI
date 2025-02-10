//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

@MainActor
@Observable
class OrdersViewModel {
    var state: UIState<[UIStore.Order]> = .loading

    private var isPreview: Bool = false
    private nonisolated let repository: StoreRepository

    init(
        repository: StoreRepository = StoreRepository()
    ) {
        self.repository = repository
    }

    func loadOrders(forced: Bool = false) async {
        guard !isPreview, state.isLoading || forced else { return }

        state = .loading

        do {
            let orders = try await getOrders()

            state = .data(data: orders)
        } catch OrdersError.networkError(let message) {
            state = .error(message: message)
        } catch {
            state = .error(message: error.localizedDescription)
        }
    }

    private func getOrders() async throws -> [UIStore.Order] {
        // Note: We are using cart response as order.
        let ordersResult = await repository.getCarts(userId: Constant.userId)

        let serverOrders: [CartItem]

        switch ordersResult {
        case .success(let orders):
            serverOrders = orders

        case .failure(_, let errorMessage, _):
            throw OrdersError.networkError(errorMessage)
        }

        var cacheProducts: [Int: UIStore.Product] = [:]
        var uiOrders = [UIStore.Order]()

        for order in serverOrders {
            var products = [UIStore.Product]()

            for product in order.products {
                if let cacheProduct = cacheProducts[product.productId] {
                    products.append(cacheProduct)
                } else {
                    let serverProduct = try await getProduct(for: product.productId)
                    products.append(serverProduct)
                    cacheProducts[product.productId] = serverProduct
                }
            }

            uiOrders.append(
                UIStore.Order(
                    id: order.id,
                    orderedAt: order.getOrderedAt(),
                    products: products
                )
            )
        }

        return uiOrders
    }

    private func getProduct(for productId: Int) async throws -> UIStore.Product {
        let result = await repository.getProductDetails(productId: productId)

        switch result {
        case .success(let product):
            return product.toUIModel()

        case .failure(_, let errorMessage, _):
            throw OrdersError.networkError(errorMessage)
        }
    }
}

enum OrdersError: Error {
    case networkError(String)
}

#if DEBUG

extension OrdersViewModel {
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
            state = .data(data: UIStore.Order.mockItems())
        }
    }
}

#endif
