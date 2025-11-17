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
public protocol ApiEndpoint: TargetType, MoyaCacheable, Sendable {
    var stubResponseType: StubResponseType { get }
    var stubStatusCode: Int { get }
    var stubData: Data? { get }
}
