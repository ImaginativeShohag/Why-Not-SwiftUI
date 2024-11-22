//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

struct NewsTypesResponse: Codable {
    let success: Bool?
    let message: String?
    let data: [NewsType]?
}

struct NewsType: Codable {
    let id: Int
    let name: String
}

#if DEBUG

extension NewsTypesResponse {
    static func mockSuccessItem() -> NewsTypesResponse {
        NewsTypesResponse(
            success: true,
            message: "success",
            data: (1 ... 20).map {
                NewsType.mockItem(
                    id: $0
                )
            }
        )
    }

    static func mockErrorItem() -> NewsTypesResponse {
        NewsTypesResponse(
            success: false,
            message: "Server error.",
            data: nil
        )
    }
}

extension NewsType {
    static func mockItem(id: Int = 1) -> NewsType {
        return NewsType(
            id: id,
            name: "News Type \(id)"
        )
    }
}

#endif
