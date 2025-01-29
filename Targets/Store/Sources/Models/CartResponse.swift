//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

typealias CartResponse = [CartItem]

// MARK: - CartResponseElement

struct CartItem: Codable {
    let id, userID: Int
    // Example: 2020-03-02T00:00:00.000Z"
    let date: String
    let products: [CartProduct]
    let v: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userId"
        case date, products
        case v = "__v"
    }
}

// MARK: - Product

struct CartProduct: Codable {
    let productID, quantity: Int

    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case quantity
    }
}
