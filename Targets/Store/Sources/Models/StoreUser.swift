//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

typealias UsersResponse = [StoreUser]

// MARK: - UsersResponseElement

struct StoreUser: Codable {
    let address: UserAddress
    let id: Int
    let email, username, password: String
    let name: UserName
    let phone: String
    let v: Int

    enum CodingKeys: String, CodingKey {
        case address, id, email, username, password, name, phone
        case v = "__v"
    }
}

// MARK: - Address

struct UserAddress: Codable {
    let geolocation: AddressGeolocation
    let city, street: String
    let number: Int
    let zipcode: String
}

// MARK: - Geolocation

struct AddressGeolocation: Codable {
    let lat, long: String
}

// MARK: - Name

struct UserName: Codable {
    let firstname, lastname: String
}
