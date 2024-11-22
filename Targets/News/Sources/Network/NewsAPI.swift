//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import Moya
import NetworkKit

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
        // Custom implementation.
        
        // Else, default value.
        return uiTestStatusCode ?? 200
    }
    
    public var stubData: Data? {
        // Custom implementation.
        
        // Else, default value.
        return uiTestStubData
    }
}
