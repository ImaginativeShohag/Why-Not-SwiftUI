//
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import Foundation

struct Fruit {
    let id = UUID().uuidString
    let name: String
    let count: Int
    var isFavorite: Bool = false

    static let items = [
        Fruit(name: "Apple", count: 10, isFavorite: true),
        Fruit(name: "Banana", count: 20, isFavorite: true),
        Fruit(name: "Blackberry", count: 30),
        Fruit(name: "Blueberry", count: 40),
        Fruit(name: "Cherry", count: 50),
        Fruit(name: "Coconut", count: 60),
        Fruit(name: "Date", count: 70, isFavorite: true),
        Fruit(name: "Dragonfruit", count: 80),
        Fruit(name: "Grape", count: 90, isFavorite: true),
        Fruit(name: "Guava", count: 10),
        Fruit(name: "Jackfruit", count: 20),
        Fruit(name: "Lemon", count: 30),
        Fruit(name: "Lychee", count: 40, isFavorite: true),
        Fruit(name: "Mango", count: 50, isFavorite: true),
        Fruit(name: "Melon", count: 60),
        Fruit(name: "Orange", count: 70),
        Fruit(name: "Olive", count: 80),
        Fruit(name: "Papaya", count: 90),
        Fruit(name: "Pineapple", count: 10),
        Fruit(name: "Raspberry", count: 20),
    ]
}
