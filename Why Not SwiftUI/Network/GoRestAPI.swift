//
//  GoRestAPI.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 8/8/22.
//

import Foundation
import Moya

let goRestProvider = MoyaProvider<GoRest>()

public enum GoRest {
    case posts
    case singlePost(Int)
}

extension GoRest: TargetType {
    public var baseURL: URL { URL(string: "https://gorest.co.in")! }

    public var path: String {
        switch self {
        case .posts:
            return "/public/v2/posts"
        case .singlePost(let postId):
            return "/public/v2/users/\(postId)/posts"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .posts:
            return .get
        case .singlePost:
            return .get
        }
    }

    public var task: Task {
        switch self {
        case .posts:
            return .requestPlain
        case .singlePost:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        [
            "Accept": "application/json",
            "Authorization": "Bearer 32374139667788b279feb06c447dfcc2e6a01a2484b1b3608ea12af2334088a6"
        ]
    }
}
