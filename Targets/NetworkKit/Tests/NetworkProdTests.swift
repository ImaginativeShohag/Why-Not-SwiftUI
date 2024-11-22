//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

#if DEBUG

@testable import NetworkKit
import XCTest
import Moya
import Alamofire

// Note: To run this test we need to enable the production environment in `Package.swift` file by adding `[.define("PRODUCTION")]` in `swiftSettings` parameter in "CoolNetworkKit" target.
final class NetworkProdTests: XCTestCase {
    var provider: Backend<MockAPI>!

    override func setUpWithError() throws {
        let session = NetworkSession.getNetworkSession()

        provider = Backend<MockAPI>(
            isStubbed: true,
            stubBehavior: .immediate,
            session: session
        ) { _, _ in }
    }

    override func tearDownWithError() throws {
        provider = nil
    }

    func setProvider(
        isStubbed: Bool = true,
        hostUrl: String = "https://example.com",
        onError: @escaping (_ route: String, _ code: Int) -> Void
    ) {
        let session = NetworkSession.getNetworkSession()

        provider = Backend<MockAPI>(
            isStubbed: isStubbed,
            stubBehavior: .immediate,
            session: session
        ) {
            onError($0, $1)
        }
    }

    func test_withTaskCancelled_shouldGetError() async throws {
        setProvider { route, code in
            XCTAssertEqual(route, MockAPI.mockGetSuccess.path)
            XCTAssertEqual(code, -1)
        }

        let task = _Concurrency.Task {
            await provider.request(GeneralResponse.self, on: .mockGetSuccess)
        }

        task.cancel()

        switch await task.value {
        case .success:
            XCTFail("Task was cancelled so it should not succeed.")

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
            XCTAssertEqual(errorMessage, "(500) Internal Server Error. Please try again.")
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

    //  MARK: - Authentication

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
            XCTFail()

        case .failure(_, let errorMessage, let statusCode):
            XCTAssertEqual(errorMessage, "(401) Unauthorized! Your session has expired. Please login again to continue.")
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

    func test_request_withServerTrustEvaluationFailed_onExampleURL_shouldFail() async throws {
        setProvider(isStubbed: false) { route, code in
            XCTAssertEqual(route, MockAPI.mockGetSuccess.path)
            XCTAssertEqual(code, -1)
        }

        let result = await provider.request(
            GeneralResponse.self,
            on: .mockGetSuccess
        )

        switch result {
        case .success:
            XCTFail("Request should not be get succeeded")

        case .failure(let error, let errorMessage, let statusCode):
            guard case MoyaError.underlying(let underlyingError, _) = error,
                  case AFError.serverTrustEvaluationFailed(reason: let reason) = underlyingError,
                  case AFError.ServerTrustFailureReason.publicKeyPinningFailed(host: _, trust: _, pinnedKeys: _, serverKeys: _) = reason
            else {
                XCTFail()
                return
            }

            XCTAssertTrue(underlyingError.asAFError?.isServerTrustEvaluationError ?? false)
            XCTAssertEqual(errorMessage, "Something went wrong. Please try again.")
            XCTAssertEqual(-1, statusCode)
        }
    }

    func test_request_withServerTrustEvaluationFailed_onEmptyURL_shouldFail() async throws {
        setProvider(
            isStubbed: false,
            hostUrl: ""
        ) { route, code in
            XCTAssertEqual(route, MockAPI.mockGetSuccess.path)
            XCTAssertEqual(code, -1)
        }

        let result = await provider.request(
            GeneralResponse.self,
            on: .mockGetSuccess
        )

        switch result {
        case .success:
            XCTFail("Request should not succeeded")

        case .failure(let error, let errorMessage, let statusCode):
            guard case MoyaError.underlying(let underlyingError, _) = error,
                  case AFError.serverTrustEvaluationFailed(reason: let reason) = underlyingError,
                  case AFError.ServerTrustFailureReason.noRequiredEvaluator = reason
            else {
                XCTFail()
                return
            }

            XCTAssertEqual(errorMessage, "Something went wrong. Please try again.")
            XCTAssertEqual(-1, statusCode)
        }
    }
}

extension Empty: Equatable {
    public static func == (lhs: Empty, rhs: Empty) -> Bool {
        true
    }
}

#endif
