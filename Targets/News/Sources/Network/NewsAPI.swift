//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import Moya

extension DataSource {
    static let News = Backend<NewsAPI>()
}

enum NewsAPI: CaseIterable {
    case allNews
    case newsTypes
}

extension NewsAPI: ApiEndpoint {
    public var baseURL: URL { URL(string: "https://raw.githubusercontent.com/ImaginativeShohag/Why-Not-SwiftUI")! }
    
    public var path: String {
        switch self {
        case .allNews:
            return "/dev/raw/news_all.json"
            
        case .newsTypes:
            return "/dev/raw/news_types.json"
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
        return [:]
    }
    
    public var stubResponseType: StubResponseType {
        return .disabled
    }
    
    public var stubStatusCode: Int {
        if let response = ProcessInfo.processInfo.environment[uiTestEnvironmentKeyResponseCode],
           let targetStatusCode = Int(response)
        {
            return targetStatusCode
        }
        
        return 200
    }
    
    public var stubData: Data? {
        if let response = ProcessInfo.processInfo.environment["\(self)"],
           let jsonData = response.data(using: .utf8)
        {
            return jsonData
        }
        
        return nil
    }
}
