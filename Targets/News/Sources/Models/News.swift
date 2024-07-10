//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

struct News: Codable, Identifiable {
    let id: Int
    let title, details: String
    let thumbnail: String
    let isFeatured: Bool
    let publishedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, details, thumbnail
        case isFeatured = "is_featured"
        case publishedAt = "published_at"
    }

    func getPublishedAt() -> Date? {
        return publishedAt.toDate(dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
    }
}
