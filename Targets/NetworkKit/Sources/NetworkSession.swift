//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Foundation
import Moya

public typealias Host = String

/// Provides factory methods for creating configured Alamofire `Session` instances
/// with optional certificate pinning support.
///
/// Use this type to create network sessions for your Backend provider with customized
/// security and caching policies.
public enum NetworkSession {
    /// Creates a configured Alamofire `Session` with optional certificate pinning.
    ///
    /// - Parameters:
    ///   - enableServerTrustManager: Whether to enable certificate pinning. Defaults to `false`.
    ///   - mappedCertificates: A dictionary mapping host names to their pinned certificates.
    ///     Only used when `enableServerTrustManager` is `true`. Defaults to an empty dictionary.
    ///   - cachePolicy: The cache policy for URL requests. Defaults to ignoring all caches.
    ///   - timeoutIntervalForRequest: The timeout interval for requests in seconds. Defaults to 60.
    ///   - httpAdditionalHeaders: Additional HTTP headers to include in all requests. Defaults to empty.
    ///
    /// - Returns: A configured `Session` instance ready for use with Moya or direct Alamofire usage.
    ///
    /// - Note: When certificate pinning is enabled, the session will only trust servers whose
    ///   public keys match those specified in `mappedCertificates`. Ensure your certificate
    ///   data is properly configured before enabling this feature.
    public static func create(
        enableServerTrustManager: Bool = false,
        mappedCertificates: [Host: [Certificate]] = [:],
        cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData,
        timeoutIntervalForRequest: TimeInterval = 60,
        httpAdditionalHeaders: [String: String] = [:]
    ) -> Session {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = cachePolicy
        config.timeoutIntervalForRequest = timeoutIntervalForRequest
        config.httpAdditionalHeaders = httpAdditionalHeaders

        let serverTrustManager: ServerTrustManager? = {
            guard enableServerTrustManager else {
                return nil
            }
            
            // Build evaluators for certificate pinning
            let evaluators: [String: ServerTrustEvaluating] = mappedCertificates.reduce(into: [:]) { result, entry in
                let (host, certificates) = entry
                result[host] = PublicKeysTrustEvaluator(keys: certificates.getSecKeys())
            }
            
            return ServerTrustManager(evaluators: evaluators)
        }()

        return Session(
            configuration: config,
            serverTrustManager: serverTrustManager
        )
    }
}
