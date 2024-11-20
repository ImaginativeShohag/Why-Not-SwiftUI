//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import NetworkKit

public extension NetworkSession {
    static let `default` = NetworkSession.getNetworkSession(
        // Note: To do certificate pinning use the following commented code.
        // serverTrustManager: ServerTrustManager.default,
        httpAdditionalHeaders: [
            "Accept": "application/json",
        ]
    )
}
