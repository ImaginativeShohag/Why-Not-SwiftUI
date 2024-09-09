//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - FruitsResponse

struct FruitsResponse: Codable {
    let success: Bool?
    let message: String?
    let data: [Fruit]?
}

// MARK: - Fruit

struct Fruit: Codable, Hashable, Identifiable {
    let name, emoji, color: String?

    var id: String { getName() }

    func getName() -> String {
        return name ?? "Unknown"
    }

    func getEmoji() -> String {
        return emoji ?? "⚠️"
    }

    func getColor() -> Color {
        return Color(hex: color ?? "#000000")
    }
}

#if DEBUG

extension Fruit {
    static func mockItems() -> [Fruit] {
        [
            Fruit(name: "Apple", emoji: "🍎", color: "#FF0800"),
            Fruit(name: "Banana", emoji: "🍌", color: "#FFE135"),
            Fruit(name: "Cherry", emoji: "🍒", color: "#DE3163"),
            Fruit(name: "Grapes", emoji: "🍇", color: "#6F2DA8"),
            Fruit(name: "Orange", emoji: "🍊", color: "#FFA500"),
            Fruit(name: "Strawberry", emoji: "🍓", color: "#FC5A8D"),
            Fruit(name: "Watermelon", emoji: "🍉", color: "#FC6C85"),
            Fruit(name: "Peach", emoji: "🍑", color: "#FFE5B4"),
            Fruit(name: "Pineapple", emoji: "🍍", color: "#F7B02D"),
            Fruit(name: "Mango", emoji: "🥭", color: "#FFCC02"),
            Fruit(name: "Lemon", emoji: "🍋", color: "#FFF700"),
            Fruit(name: "Blueberry", emoji: "🫐", color: "#4F86F7"),
            Fruit(name: "Pear", emoji: "🍐", color: "#D1E231"),
            Fruit(name: "Kiwi", emoji: "🥝", color: "#8EE53F"),
            Fruit(name: "Coconut", emoji: "🥥", color: "#965A3E")
        ]
    }
}

#endif
