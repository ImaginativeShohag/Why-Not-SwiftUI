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
    public var baseURL: URL { URL(string: "https://raw.githubusercontent.com/ImaginativeShohag/Why-Not-SwiftUI")! }
    
    public var path: String {
        switch self {
        case .allNews:
            return "/dev/raw/news_all.json"
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
        if CommandLine.arguments.contains(uiTestArgResponseSuccess) {
            return .success
        } else if CommandLine.arguments.contains(uiTestArgResponseFailure) {
            return .failure
        } else if CommandLine.arguments.contains(uiTestArgResponseError) {
            return .error
        }
        
        return .disabled
    }
    
    public var stubStatusCode: Int {
        switch stubResponseType {
        case .failure:
            return 500
            
        default:
            return 200
        }
    }
    
    public var stubData: Data? {
        #if DEBUG
        switch self {
        case .allNews:
            switch stubResponseType {
            case .failure:
                return nil
                
            case .error:
                return AllNewsResponse.mockErrorItem().toData()
                
            default:
                return AllNewsResponse.mockSuccessItem().toData()
            }
        }
        #else
        return nil
        #endif
    }
}
