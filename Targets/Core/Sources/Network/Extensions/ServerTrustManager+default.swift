//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Foundation
import NetworkKit

public extension ServerTrustManager {
    static var `default`: ServerTrustManager {
        let domainName = URL(string: Env.shared.hostUrl)?.host ?? ""
        let evaluators: [String: ServerTrustEvaluating] = [
            domainName: PublicKeysTrustEvaluator(keys: CertificateManager.default.publicKeys),
        ]

        return ServerTrustManager(evaluators: evaluators)
    }
}
