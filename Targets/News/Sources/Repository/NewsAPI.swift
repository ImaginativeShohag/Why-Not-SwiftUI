//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import Moya

extension DataSource {
    static let News = Backend<NewsAPI>()
}

enum NewsAPI {
    case allNews
}

extension NewsAPI: ApiEndpoint {
    public var baseURL: URL { URL(string: Env.shared.baseURL)! }
    
    public var path: String {
        switch self {
        case .allNews:
            return "/v1/user/validate"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        default:
            return .requestPlain
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .allNews:
            return [:]
        }
    }
    
    public var stubResponseType: StubResponseType {
        return .disabled
    }
    
    public var stubStatusCode: Int {
        return 200
    }
    
    public var stubData: Data? {
        switch self {
        case .allNews:
            return #"""
            {"success":true,"message":"Request processed successfully","token":"lorem-ipsum"}
            """#.data(using: .utf8)
        }
    }
}
