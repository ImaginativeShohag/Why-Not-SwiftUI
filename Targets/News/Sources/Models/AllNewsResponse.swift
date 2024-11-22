//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

struct AllNewsResponse: Codable {
    let success: Bool?
    let message: String?
    let news: [News]?
}

#if DEBUG

extension AllNewsResponse {
    static func mockSuccessItem() -> AllNewsResponse {
        AllNewsResponse(
            success: true,
            message: "success",
            news: (1 ... 20).map {
                News.mockItem(
                    id: $0,
                    isFeatured: $0 % 2 == 0 ? true : false
                )
            }
        )
    }

    static func mockErrorItem() -> AllNewsResponse {
        AllNewsResponse(
            success: false,
            message: "Server error.",
            news: nil
        )
    }
}

#endif
