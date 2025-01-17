//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Moya
import SuperLog

/// This protocol will be used to define cache policy for the requests.
public protocol MoyaCacheable {
    /// The cache policy to be used in the request.
    var cachePolicy: URLRequest.CachePolicy { get }
}

final class MoyaCacheablePlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let cacheableTarget = target as? MoyaCacheable {
            var mutableRequest = request
            mutableRequest.cachePolicy = cacheableTarget.cachePolicy
            SuperLog.v("cachePolicy: \(cacheableTarget.cachePolicy)")
            return mutableRequest
        }

        return request
    }
}
