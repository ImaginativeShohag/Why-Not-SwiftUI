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

#if DEBUG

extension News {
    static func mockItem(id: Int = 1, isFeatured: Bool = true) -> News {
        News(
            id: id,
            title: "Lorem Ipsum",
            details: "sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
            thumbnail: "https://picsum.photos/id/\(id)/300/200",
            isFeatured: true,
            publishedAt: "2024-07-01T10:00:00+00:00"
        )
    }
}

#endif
