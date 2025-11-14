//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

// MARK: - StoreUser

struct StoreUser: Codable {
    let address: UserAddress?
    let id: Int
    let email, username, password: String
    let name: UserName
    let phone: String

    enum CodingKeys: String, CodingKey {
        case address, id, email, username, password, name, phone
    }

    init(
        id: Int,
        email: String,
        username: String,
        password: String,
        name: UserName,
        phone: String,
        address: UserAddress?
    ) {
        self.address = address
        self.id = id
        self.email = email
        self.username = username
        self.password = password
        self.name = name
        self.phone = phone
    }
}

// MARK: - Address

struct UserAddress: Codable {
    let geolocation: AddressGeolocation
    let city, street: String
    let number: Int
    let zipcode: String

    func getAddress() -> String {
        return "\(street), \(city)"
    }
}

// MARK: - Geolocation

struct AddressGeolocation: Codable {
    let lat, long: String
}

// MARK: - Name

struct UserName: Codable {
    let firstname, lastname: String

    func getFullName() -> String {
        return "\(firstname) \(lastname)"
    }
}

#if DEBUG

extension StoreUser {
    static func mockItem() -> StoreUser {
        StoreUser(
            id: 1,
            email: "lorem@example.com",
            username: "loremipsum",
            password: "123456",
            name: UserName(firstname: "Lorem", lastname: "Ipsum"),
            phone: "0123456789",
            address: UserAddress(
                geolocation: AddressGeolocation(lat: "0.0", long: "0.0"),
                city: "Center Mars",
                street: "Fast Lane",
                number: 1234,
                zipcode: "123-456"
            )
        )
    }
}

#endif
