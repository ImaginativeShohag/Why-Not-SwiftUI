//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Foundation
import Moya

/// This enum will only be used to call
/// ``getNetworkSession(hostUrl:enableServerTrustManager:cachePolicy:timeoutIntervalForRequest:httpAdditionalHeaders:)``
///  function while initializing the Backend provider.
public enum NetworkSession {
    public static func getNetworkSession(
        hostUrl: String,
        enableServerTrustManager: Bool = false,
        cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
        timeoutIntervalForRequest: TimeInterval = 60,
        httpAdditionalHeaders: [String: String] = [:]
    ) -> Session {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = cachePolicy
        config.timeoutIntervalForRequest = timeoutIntervalForRequest
        config.httpAdditionalHeaders = httpAdditionalHeaders

        var serverTrustManager: ServerTrustManager? = nil

        if enableServerTrustManager {
            // MARK: Certificate Pinning

            let domainName = URL(string: hostUrl)?.host ?? ""
            let evaluators: [String: ServerTrustEvaluating] = [
                domainName: PublicKeysTrustEvaluator(keys: STCertificateManager.shared.publicKeys),
            ]

            serverTrustManager = ServerTrustManager(evaluators: evaluators)
        }

        return Session(
            configuration: config,
            serverTrustManager: serverTrustManager
        )
    }
}
