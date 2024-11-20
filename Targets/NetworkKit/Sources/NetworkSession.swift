//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Foundation
import Moya

/// This enum will only be used to call
/// ``getNetworkSession(serverTrustManager:cachePolicy:timeoutIntervalForRequest:httpAdditionalHeaders:)``
///  function while initializing the Backend provider.
public enum NetworkSession {
    public static func getNetworkSession(
        serverTrustManager: ServerTrustManager? = nil,
        cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
        timeoutIntervalForRequest: TimeInterval = 60,
        httpAdditionalHeaders: [String: String] = [:]
    ) -> Session {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = cachePolicy
        config.timeoutIntervalForRequest = timeoutIntervalForRequest
        config.httpAdditionalHeaders = httpAdditionalHeaders

        return Session(
            configuration: config,
            serverTrustManager: serverTrustManager
        )
    }
}
