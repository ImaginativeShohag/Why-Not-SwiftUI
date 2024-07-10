//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import Moya

public enum MockAPI {
    case mockGetSuccess
    case mockGetFail
    case mockGetError
    case mockGetErrorWithNoData
    case mockGetErrorWithUnparsableData
}

extension MockAPI: ApiEndpoint {
    public var baseURL: URL { URL(string: "https://example.com")! }

    public var path: String {
        switch self {
        case .mockGetSuccess:
            return "/api/mock-get-success"

        case .mockGetFail:
            return "/api/mock-get-fail"

        case .mockGetError:
            return "/api/mock-get-error"

        case .mockGetErrorWithNoData:
            return "/api/mock-get-error-with-no-data"

        case .mockGetErrorWithUnparsableData:
            return "/api/mock-get-error-with-unparsable-data"
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

    public var stubResponseType: StubResponseType {
        switch self {
        case .mockGetSuccess:
            return .success

        case .mockGetFail:
            return .failure

        case .mockGetError:
            return .error

        case .mockGetErrorWithNoData:
            return .error

        case .mockGetErrorWithUnparsableData:
            return .error
        }
    }

    public var stubStatusCode: Int {
        switch self {
        case .mockGetSuccess:
            return 200

        case .mockGetFail:
            return 200

        case .mockGetError:
            return 401

        case .mockGetErrorWithNoData:
            return 500

        case .mockGetErrorWithUnparsableData:
            return 500
        }
    }

    public var stubData: Data? {
        switch self {
        case .mockGetSuccess:
            return #"""
            {
              "success": true,
              "message": "Request processed successfully",
            }
            """#.data(using: .utf8)

        case .mockGetFail:
            return #"""
            {
              "success": false,
              "message": "Request is failed",
            }
            """#.data(using: .utf8)

        case .mockGetError:
            return #"""
            {
              "message": "Unauthenticated",
            }
            """#.data(using: .utf8)

        case .mockGetErrorWithNoData:
            return nil

        case .mockGetErrorWithUnparsableData:
            return #"""
            <!DOCTYPE html>
            <html>
                <head>
                </head>
                <body>
                </body>
            </html>
            """#.data(using: .utf8)
        }
    }

    public var headers: [String: String]? {
        nil
    }
}
