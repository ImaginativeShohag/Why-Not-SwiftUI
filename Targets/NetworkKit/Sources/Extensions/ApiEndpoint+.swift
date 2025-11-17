//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

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
