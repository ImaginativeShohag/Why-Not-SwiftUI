//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

struct AllNewsResponse: Codable {
    let success: Bool?
    let message: String?
    let news: [News]?
}
