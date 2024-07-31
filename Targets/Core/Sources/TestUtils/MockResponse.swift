//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

struct MockResponse {
    let route: ApiEndpoint
    let statusCode: Int
    let data: Encodable?
}
