//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import NetworkKit
import Foundation

public struct MockResponse {
    let route: ApiEndpoint
    let statusCode: Int
    let data: Encodable?

    public init(
        route: ApiEndpoint,
        statusCode: Int,
        data: Encodable?
    ) {
        self.route = route
        self.statusCode = statusCode
        self.data = data
    }
}
