//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - FlowersResponse

struct FlowersResponse: Codable {
    let success: Bool?
    let message: String?
    let data: [Flower]?
}

// MARK: - Datum

struct Flower: Codable, Hashable, Identifiable {
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

extension Flower {
    static func mockItems() -> [Flower] {
        [
            Flower(name: "Rose", emoji: "🌹", color: "#FF007F"),
            Flower(name: "Sunflower", emoji: "🌻", color: "#FFD700"),
            Flower(name: "Tulip", emoji: "🌷", color: "#FF6347"),
            Flower(name: "Cherry Blossom", emoji: "🌸", color: "#FFB7C5"),
            Flower(name: "Hibiscus", emoji: "🌺", color: "#FF69B4"),
            Flower(name: "Lotus", emoji: "🪷", color: "#F4C2C2"),
            Flower(name: "Blossom", emoji: "🌼", color: "#FFFACD"),
            Flower(name: "Lavender", emoji: "💐", color: "#E6E6FA"),
            Flower(name: "Blossoming Heart", emoji: "💮", color: "#F08080"),
            Flower(name: "Rose Bouquet", emoji: "💐", color: "#FF69B4"),
            Flower(name: "Daisy", emoji: "🌼", color: "#FFFFE0"),
            Flower(name: "Orchid", emoji: "🌸", color: "#DA70D6"),
            Flower(name: "Iris", emoji: "🌸", color: "#5A4FCF"),
            Flower(name: "Lily", emoji: "🌺", color: "#E5A0D4"),
            Flower(name: "Peony", emoji: "🌸", color: "#FFC0CB"),
            Flower(name: "Poppy", emoji: "🌺", color: "#FF4500"),
            Flower(name: "Marigold", emoji: "🌼", color: "#FFAF1F"),
        ]
    }
}
