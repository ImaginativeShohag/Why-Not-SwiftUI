//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

#if DEBUG

import Alamofire
import Moya
@testable import NetworkKit
import XCTest

final class NetworkKitTests: XCTestCase {
    var provider: Backend<MockAPI>!

    override func setUpWithError() throws {
        setProvider { _, _ in }
    }

    override func tearDownWithError() throws {
        provider = nil
    }

    /// - Note: We are using this to utilize the `onError` callback.
    func setProvider(
        isStubbed: Bool = true,
        onError: @escaping (_ route: String, _ code: Int) -> Void
    ) {
        let session = NetworkSession.create(
            enableServerTrustManager: true,
            mappedCertificates: ["example.com": [CertificateStore.mockPEMKeyForExampleDotCom]]
        )

        provider = Backend<MockAPI>(
            isStubbed: isStubbed,
            stubBehavior: .immediate,
            session: session
        ) {
            onError($0, $1)
        }
    }

    // MARK: - Tests

    func test_request_withSuccessResponse_shouldSucceed() async throws {
        let result = await provider.request(GeneralResponse.self, on: .mockGetSuccess)

        switch result {
        case .success(let response):
            XCTAssertTrue(response.isSuccess())
            XCTAssertEqual(response.getMessage(), "Request processed successfully.")

        case .failure(let error, let errorMessage, let statusCode):
            XCTFail("Request failed: (\(statusCode)): \(errorMessage) \n\n \(error)")
        }
    }

    // This is for testing a different variant of request method.
    func test_request_withSuccessResponse_withDifferentRequestMethod_shouldSucceed() async throws {
        let result: ApiResult<GeneralResponse> = await provider.request(on: .mockGetSuccess)

        switch result {
        case .success(let response):
            XCTAssertTrue(response.isSuccess())
            XCTAssertEqual(response.getMessage(), "Request processed successfully.")

        case .failure(let error, let errorMessage, let statusCode):
            XCTFail("Request failed: (\(statusCode)): \(errorMessage) \n\n \(error)")
        }
    }

    func test_request_withFailResponse_shouldGetFailedResult() async throws {
        let result = await provider.request(GeneralResponse.self, on: .mockGetFail)

        switch result {
        case .success(let response):
            XCTAssertFalse(response.isSuccess())
            XCTAssertEqual(response.getMessage(), "Something went wrong. Try again.")

        case .failure(let error, let errorMessage, let statusCode):
            XCTFail("Request failed: (\(statusCode)): \(errorMessage) \n\n \(error)")
        }
    }

    func test_request_withErrorResponse_shouldFail() async throws {
        let result = await provider.request(GeneralResponse.self, on: .mockGetError)

        switch result {
        case .success:
            XCTFail("Request should not succeed.")

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(statusCode, 500)
            XCTAssertEqual(errorMessage, "Request failed.")
        }
    }

    func test_request_withEmptyErrorResponse_shouldGetHttpStatusCodeMessage() async throws {
        let result = await provider.request(GeneralResponse.self, on: .mockGetErrorWithNoData)

        switch result {
        case .success(let response):
            if response.isSuccess() {
                XCTFail("Request should not be get succeeded.")
            } else {
                XCTFail("Request not success: \(response.getMessage()).")
            }

        case .failure(_, let errorMessage, _):
            XCTAssertEqual(errorMessage, "(500) \(HttpStatusCode.getMessage(for: 500))")
        }
    }

    func test_request_withUnParsableErrorResponse_shouldGetHttpStatusCodeMessage() async throws {
        let result = await provider.request(GeneralResponse.self, on: .mockGetErrorWithNoData)

        switch result {
        case .success(let response):
            if response.isSuccess() {
                XCTFail("Request should not be get succeeded.")
            } else {
                XCTFail("Request not success: \(response.getMessage())")
            }

        case .failure(_, let errorMessage, _):
            XCTAssertEqual(errorMessage, "(500) \(HttpStatusCode.getMessage(for: 500))")
        }
    }

    func test_request_withNoMatchedCertificate_shouldFail() async throws {
        let session = NetworkSession.create(
            enableServerTrustManager: true,
            mappedCertificates: ["example.com": [CertificateStore.mockPEMKeyForExampleDotCom]]
        )

        let provider = Backend<MockAPI>(
            isStubbed: false,
            session: session
        )

        let result = await provider.request(GeneralResponse.self, on: .mockRequestCustomEndpoint("https://httpbin.org"))

        switch result {
        case .success(let response):
            if response.isSuccess() {
                XCTFail("Request should not be get succeeded.")
            } else {
                XCTFail("Request not success: \(response.getMessage()).")
            }

        case .failure(let error, _, _):
            guard case MoyaError.underlying(let underlyingError, _) = error,
                  case AFError.serverTrustEvaluationFailed(reason: let reason) = underlyingError,
                  case AFError.ServerTrustFailureReason.noPublicKeysFound = reason
            else {
                XCTFail("\(error)")
                return
            }
        }
    }

    func test_request_withEmptyCertificateList_shouldFail() async throws {
        let session = NetworkSession.create(
            enableServerTrustManager: true
        )

        let provider = Backend<MockAPI>(
            isStubbed: false,
            session: session
        )

        let result = await provider.request(GeneralResponse.self, on: .mockRequestCustomEndpoint("https://httpbin.org"))

        switch result {
        case .success(let response):
            if response.isSuccess() {
                XCTFail("Request should not be get succeeded.")
            } else {
                XCTFail("Request not success: \(response.getMessage()).")
            }

        case .failure(let error, _, _):
            guard case MoyaError.underlying(let underlyingError, _) = error,
                  case AFError.serverTrustEvaluationFailed(reason: let reason) = underlyingError,
                  case AFError.ServerTrustFailureReason.noRequiredEvaluator = reason
            else {
                XCTFail("\(error)")
                return
            }
        }
    }

    func test_withTaskCancelled_shouldGetError() async throws {
        let session = NetworkSession.create()

        let provider = Backend<MockAPI>(
            isStubbed: true,
            stubBehavior: .immediate,
            session: session
        ) { route, code in
            XCTAssertEqual(route, MockAPI.mockGetSuccess.path)
            XCTAssertEqual(code, -1)
        }

        let task = _Concurrency.Task {
            await provider.request(GeneralResponse.self, on: .mockGetSuccess)
        }

        task.cancel()

        switch await task.value {
        case .success:
            XCTFail("Task was canceled so it should not succeed.")

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(statusCode, -1)
            XCTAssertEqual(errorMessage, "Request cancelled!")
        }
    }

    func test_withSuccessResponse_withWrongModel_shouldGetMappingError() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetSuccess.path)
            XCTAssertEqual(code, 200)
        }

        let result = await provider.request(String.self, on: .mockGetSuccess)

        switch result {
        case .success:
            XCTFail()

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(errorMessage, "Invalid server response. Please try again.")
            XCTAssertEqual(200, statusCode)
        }
    }

    func test_request_withErrorResponse_shouldGetStatusCodeError() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetError.path)
            XCTAssertEqual(code, 500)
        }

        let result = await provider.request(GeneralResponse.self, on: .mockGetError)

        switch result {
        case .success:
            XCTFail()

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(errorMessage, "Request failed.")
            XCTAssertEqual(500, statusCode)
        }
    }

    func test_request_withErrorResponse_shouldGetGenericErrorMessage() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetFail.path)
            XCTAssertEqual(code, 200)
        }

        let result = await provider.request(String.self, on: .mockGetFail)

        switch result {
        case .success:
            XCTFail()

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(errorMessage, "Invalid server response. Please try again.")
            XCTAssertEqual(200, statusCode)
        }
    }

    func test_request_withAuthenticationError_shouldFail() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetAuthenticationError.path)
            XCTAssertEqual(code, 401)
        }

        let result = await provider.request(
            GeneralResponse.self,
            on: .mockGetAuthenticationError
        )

        switch result {
        case .success:
            XCTFail("Request should not succeed.")

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(errorMessage, "Unauthenticated.")
            XCTAssertEqual(401, statusCode)
        }
    }

    func test_request_withSuccess_withEmptyResponse_withWrongModel_shouldFail() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetSuccessWithEmpty.path)
            XCTAssertEqual(code, 200)
        }

        let result = await provider.request(
            GeneralResponse.self,
            on: .mockGetSuccessWithEmpty
        )

        switch result {
        case .success:
            XCTFail()

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(errorMessage, "Invalid server response. Please try again.")
            XCTAssertEqual(200, statusCode)
        }
    }

    func test_request_withSuccess_withEmptyResponse_withEmptyModel_shouldSucceed() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetSuccessWithEmpty.path)
            XCTAssertEqual(code, 200)
        }

        let result = await provider.request(
            Empty.self,
            on: .mockGetSuccessWithEmpty
        )

        switch result {
        case .success(let response):
            XCTAssertEqual(response, Empty.value)

        case .failure:
            XCTFail()
        }
    }

    func test_request_withSuccess_withNilResponse_withEmptyModel_shouldSucceed() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetSuccessWithNil.path)
            XCTAssertEqual(code, 200)
        }

        let result = await provider.request(
            Empty.self,
            on: .mockGetSuccessWithNil
        )

        switch result {
        case .success(let response):
            XCTAssertEqual(response, Empty.value)

        case .failure:
            XCTFail()
        }
    }

    func test_request_withSuccess_withNoData_withEmptyModel_shouldSucceed() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetSuccessWithNoData.path)
            XCTAssertEqual(code, 200)
        }

        let result = await provider.request(
            Empty.self,
            on: .mockGetSuccessWithNoData
        )

        switch result {
        case .success(let response):
            XCTAssertEqual(response, Empty.value)

        case .failure:
            XCTFail()
        }
    }

    func test_request_withSuccess_withUnParsableData_shouldFailToParse() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetErrorWithUnParsableData.path)
            XCTAssertEqual(code, 500)
        }

        let result = await provider.request(
            GeneralResponse.self,
            on: .mockGetErrorWithUnParsableData
        )

        switch result {
        case .success:
            XCTFail()

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(errorMessage, "(500) Internal Server Error. Please try again.")
            XCTAssertEqual(500, statusCode)
        }
    }

    func test_request_withSuccess_withNoData_shouldFailToParse() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetErrorWithNoData.path)
            XCTAssertEqual(code, 500)
        }

        let result = await provider.request(
            GeneralResponse.self,
            on: .mockGetErrorWithNoData
        )

        switch result {
        case .success:
            XCTFail()

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(errorMessage, "(500) Internal Server Error. Please try again.")
            XCTAssertEqual(500, statusCode)
        }
    }

    func test_request_withError_withEmptyResponse_shouldFail() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetErrorWithEmpty.path)
            XCTAssertEqual(code, 500)
        }

        let result = await provider.request(
            GeneralResponse.self,
            on: .mockGetErrorWithEmpty
        )

        switch result {
        case .success:
            XCTFail()

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(errorMessage, "(500) Internal Server Error. Please try again.")
            XCTAssertEqual(500, statusCode)
        }
    }

    // MARK: `parseResponseErrorMessage(from:)`

    func test_parseResponseErrorMessage_withStatusCodeError_shouldGetParsedMessage() async throws {
        let error = MoyaError.statusCode(
            Response(
                statusCode: MockAPI.mockGetError.stubStatusCode,
                data: MockAPI.mockGetError.stubData ?? Data()
            )
        )

        let errorMessage = provider.public_parseResponseErrorMessage(from: error)
        XCTAssertEqual(errorMessage, "Request failed.")
    }

    func test_parseResponseErrorMessage_withParsableResponse_withStatusCodeError_shouldGetParsedMessage() async throws {
        let error = MoyaError.statusCode(
            Response(
                statusCode: 500,
                data: """
                {
                  "success": false,
                  "message": "Request failed.",
                }
                """.data(using: .utf8) ?? Data()
            )
        )

        let errorMessage = provider.public_parseResponseErrorMessage(from: error)
        XCTAssertEqual(errorMessage, "Request failed.")
    }

    func test_parseResponseErrorMessage_withEmptyObjectResponse_withStatusCodeError_shouldGetParsedMessage() async throws {
        let error = MoyaError.statusCode(
            Response(
                statusCode: 500,
                data: "{}".data(using: .utf8) ?? Data()
            )
        )

        let errorMessage = provider.public_parseResponseErrorMessage(from: error)
        XCTAssertEqual(errorMessage, "Something went wrong. Try again.")
    }

    func test_parseResponseErrorMessage_withEmptyResponse_withObjectMappingError_shouldGetNil() async throws {
        let error = MoyaError.statusCode(
            Response(
                statusCode: 200,
                data: "".data(using: .utf8) ?? Data()
            )
        )

        let errorMessage = provider.public_parseResponseErrorMessage(from: error)
        XCTAssertNil(errorMessage)
    }

    func test_parseResponseErrorMessage_withUnParsableResponse_withObjectMappingError_shouldGetNil() async throws {
        let error = MoyaError.objectMapping(
            StubError.dummy,
            Response(
                statusCode: 200,
                data: """
                <!DOCTYPE html>
                <html>
                    <head>
                    </head>
                    <body>
                    </body>
                </html>
                """.data(using: .utf8) ?? Data()
            )
        )

        let errorMessage = provider.public_parseResponseErrorMessage(from: error)
        XCTAssertNil(errorMessage)
    }

    // MARK: `getErrorMessage(for:)`

    func test_getErrorMessage_withStatusCodeError_shouldGetDefaultMessageFromFunction() async throws {
        let error = MoyaError.statusCode(
            Response(
                statusCode: 541,
                data: "".data(using: .utf8) ?? Data()
            )
        )

        let errorMessage = provider.public_getErrorMessage(for: error)
        XCTAssertEqual(errorMessage, "Something went wrong. Please try again!")
    }

    func test_getErrorMessage_withStatusCodeError_shouldGetMessageFromStatusCodeDictionary() async throws {
        let error1 = MoyaError.statusCode(
            Response(
                statusCode: 500,
                data: "".data(using: .utf8) ?? Data()
            )
        )

        let errorMessage1 = provider.public_getErrorMessage(for: error1)
        XCTAssertEqual(errorMessage1, "Internal Server Error. Please try again.")

        let error2 = MoyaError.statusCode(
            Response(
                statusCode: 401,
                data: "".data(using: .utf8) ?? Data()
            )
        )

        let errorMessage2 = provider.public_getErrorMessage(for: error2)
        XCTAssertEqual(errorMessage2, "Unauthorized! Your session has expired. Please login again to continue.")

        let error3 = MoyaError.statusCode(
            Response(
                statusCode: 404,
                data: "".data(using: .utf8) ?? Data()
            )
        )

        let errorMessage3 = provider.public_getErrorMessage(for: error3)
        XCTAssertEqual(errorMessage3, "Not Found! The server could not find the requested resource.")
    }

    func test_getErrorMessage_withUnderlyingAFError_shouldGetMessageFromSessionTaskError() async throws {
        let error = MoyaError.underlying(
            AFError.sessionTaskFailed(error: StubError.dummy),
            Response(
                statusCode: 202,
                data: "".data(using: .utf8) ?? Data()
            )
        )

        let errorMessage = provider.public_getErrorMessage(for: error)
        XCTAssertEqual(errorMessage, "Dummy error.")
    }

    func test_getErrorMessage_withUnderlyingError_shouldGetMessageFromUnderlyingError() async throws {
        let error = MoyaError.underlying(
            StubError.dummy,
            Response(
                statusCode: 202,
                data: "".data(using: .utf8) ?? Data()
            )
        )

        let errorMessage = provider.public_getErrorMessage(for: error)
        XCTAssertEqual(errorMessage, "Dummy error.")
    }

    func test_getErrorMessage_withUnderlyingError_shouldGetMessageFromUnderlyingError3() async throws {
        let error = MoyaError.requestMapping("Failed to map Endpoint to a URLRequest.")

        let errorMessage = provider.public_getErrorMessage(for: error)
        XCTAssertEqual(errorMessage, "Failed to map Endpoint to a URLRequest.")
    }
}

// MARK: - Errors

private enum StubError: Error {
    case dummy
}

extension StubError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .dummy:
            return "Dummy error."
        }
    }
}

#endif
