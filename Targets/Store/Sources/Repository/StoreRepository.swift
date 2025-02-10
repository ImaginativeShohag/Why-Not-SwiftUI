//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import NetworkKit

final class StoreRepository: Sendable {
    func login(username: String, password: String) async -> ApiResult<LoginResponse> {
        return await DataSource.Store.request(
            on: .login(username: username, password: password)
        )
    }
    
    func getUserDetails(userId: Int) async -> ApiResult<StoreUser> {
        return await DataSource.Store.request(
            on: .userDetails(userId: userId)
        )
    }
    
    func getProducts() async -> ApiResult<ProductListResponse> {
        return await DataSource.Store.request(
            on: .products
        )
    }
    
    func getProductDetails(productId: Int) async -> ApiResult<Product> {
        return await DataSource.Store.request(
            on: .productDetails(productId: productId)
        )
    }
    
    func getCategories() async -> ApiResult<CategoryListResponse> {
        return await DataSource.Store.request(
            on: .categories
        )
    }
    
    func getCategoryProducts(categoryId: Category) async -> ApiResult<ProductListResponse> {
        return await DataSource.Store.request(
            on: .categoryProducts(categoryId: categoryId)
        )
    }
    
    func getCarts(userId: Int) async -> ApiResult<CartResponse> {
        return await DataSource.Store.request(
            on: .carts(userId: userId)
        )
    }
}
