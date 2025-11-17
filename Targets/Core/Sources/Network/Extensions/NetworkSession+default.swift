//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import NetworkKit

public extension NetworkSession {
    static let `default` = NetworkSession.create(
        httpAdditionalHeaders: [
            "Accept": "application/json",
        ]
    )
}
