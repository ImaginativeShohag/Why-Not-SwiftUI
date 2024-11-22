//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Moya

/// The protocol used to define the specifications necessary for a `MoyaProvider`.
///
/// Types conforming to `ApiEndpoint` define the necessary information and behavior
/// required to construct and interact with an API endpoint, including its path, HTTP method,
/// request parameters, headers, and response parsing logic.
public protocol ApiEndpoint: TargetType, MoyaCacheable {
    var stubResponseType: StubResponseType { get }
    var stubStatusCode: Int { get }
    var stubData: Data? { get }
}

public extension ApiEndpoint {
    static var dispatchLabel: String { String(describing: Self.self) }

    // ----------------------------------------------------------------
    // UI test related implementations
    // ----------------------------------------------------------------

    var uiTestStatusCode: Int? {
        if let response = ProcessInfo.processInfo.environment["\(uiTestEnvKeyResponseStatusCode)-\(self)"],
           let targetStatusCode = Int(response)
        {
            return targetStatusCode
        }

        return nil
    }

    var uiTestStubData: Data? {
        if let response = ProcessInfo.processInfo.environment["\(self)"],
           let jsonData = response.data(using: .utf8)
        {
            return jsonData
        }

        return nil
    }

    // ----------------------------------------------------------------

    var stubResponseType: StubResponseType { .disabled }
    var stubStatusCode: Int { uiTestStatusCode ?? -1 }
    var stubData: Data? { uiTestStubData }

    var sampleData: Data { stubData ?? Data() }
    var cachePolicy: URLRequest.CachePolicy { .reloadIgnoringLocalAndRemoteCacheData }
}
