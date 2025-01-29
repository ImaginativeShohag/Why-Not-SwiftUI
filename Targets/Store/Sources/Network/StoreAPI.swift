//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import Moya
import NetworkKit

extension DataSource {
    static let Store = Backend<NewsAPI>()
}

enum NewsAPI {
    case login(username: String, password: String)
    case userDetails(userId: Int)
    case products
    case productDetails(productId: Int)
    case categories
    case categoryProducts(categoryId: Category)
    case carts(userId: Int)
}

extension NewsAPI: ApiEndpoint {
    public var baseURL: URL { URL(string: "https://fakestoreapi.com")! }
    
    public var path: String {
        switch self {
        case .login:
            "/auth/login"
            
        case .userDetails(let userId):
            "/users/\(userId)"
            
        case .products:
            "/products"
            
        case .productDetails(let productId):
            "/products/\(productId)"
            
        case .categories:
            "/products/categories"
            
        case .categoryProducts(let categoryId):
            "/products/category/\(categoryId)"
            
        case .carts(let userId):
            "/carts?userId=\(userId)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .login:
            return .post
            
        default:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .login(let username, let password):
            return .requestParameters(
                parameters: [
                    "username": username,
                    "password": password
                ],
                encoding: JSONEncoding()
            )
            
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
