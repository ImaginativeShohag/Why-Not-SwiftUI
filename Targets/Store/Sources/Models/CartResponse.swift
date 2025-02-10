//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

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
    
    func getOrderedAt() -> Date? {
        date.isEmpty ? nil : date.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSX")
    }
}

// MARK: - Product

struct CartProduct: Codable {
    let productId, quantity: Int
}
