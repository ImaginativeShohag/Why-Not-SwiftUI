//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import NetworkKit
import Foundation
import Moya

public enum MockAPI {
    case mockGetSuccess
    case mockGetFail
    case mockGetError
    case mockGetAuthenticationError
    case mockGetErrorWithNoData
    case mockGetSuccessWithNoData
    case mockGetErrorWithUnParsableData
    case mockGetErrorWithEmpty
    case mockGetSuccessWithEmpty
    case mockGetSuccessWithNil
    case mockRequestCustomEndpoint(_ endpoint: String)
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

        case .mockGetAuthenticationError:
            return "/api/mock-get-authentication-error"

        case .mockGetErrorWithNoData:
            return "/api/mock-get-error-with-no-data"

        case .mockGetSuccessWithNoData:
            return "/api/mock-get-success-with-no-data"

        case .mockGetErrorWithUnParsableData:
            return "/api/mock-get-error-with-unparsable-data"

        case .mockGetErrorWithEmpty:
            return "/api/mock-get-error-with-empty"

        case .mockGetSuccessWithEmpty:
            return "/api/mock-get-success-with-empty"

        case .mockGetSuccessWithNil:
            return "/api/mock-get-success-with-nil"

        case .mockRequestCustomEndpoint(let endpoint):
            return endpoint
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

        case .mockGetAuthenticationError:
            return .error

        case .mockGetErrorWithNoData:
            return .error

        case .mockGetSuccessWithNoData:
            return .success

        case .mockGetErrorWithUnParsableData:
            return .error

        case .mockGetErrorWithEmpty:
            return .error

        case .mockGetSuccessWithEmpty:
            return .success

        case .mockGetSuccessWithNil:
            return .success

        case .mockRequestCustomEndpoint:
            return .success
        }
    }

    public var stubStatusCode: Int {
        switch self {
        case .mockGetSuccess:
            return 200

        case .mockGetFail:
            return 200

        case .mockGetError:
            return 500

        case .mockGetAuthenticationError:
            return 401

        case .mockGetErrorWithNoData:
            return 500

        case .mockGetSuccessWithNoData:
            return 200

        case .mockGetErrorWithUnParsableData:
            return 500

        case .mockGetErrorWithEmpty:
            return 500

        case .mockGetSuccessWithEmpty:
            return 200

        case .mockGetSuccessWithNil:
            return 200

        case .mockRequestCustomEndpoint:
            return 200
        }
    }

    public var stubData: Data? {
        switch self {
        case .mockGetSuccess:
            return #"""
            {
              "success": true,
              "message": "Request processed successfully.",
            }
            """#.data(using: .utf8)

        case .mockGetFail:
            return #"{}"#.data(using: .utf8)

        case .mockGetError:
            return #"""
            {
              "success": false,
              "message": "Request failed.",
            }
            """#.data(using: .utf8)

        case .mockGetAuthenticationError:
            return #"""
            {
              "message": "Unauthenticated.",
            }
            """#.data(using: .utf8)

        case .mockGetErrorWithNoData:
            return nil

        case .mockGetSuccessWithNoData:
            return nil

        case .mockGetErrorWithUnParsableData:
            return #"""
            <!DOCTYPE html>
            <html>
                <head>
                </head>
                <body>
                </body>
            </html>
            """#.data(using: .utf8)

        case .mockGetErrorWithEmpty:
            return "".data(using: .utf8)

        case .mockGetSuccessWithEmpty:
            return "".data(using: .utf8)

        case .mockGetSuccessWithNil:
            return nil

        case .mockRequestCustomEndpoint:
            return nil
        }
    }

    public var headers: [String: String]? {
        nil
    }
}
