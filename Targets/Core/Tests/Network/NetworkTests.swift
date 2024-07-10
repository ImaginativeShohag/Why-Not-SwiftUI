//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import XCTest
import Moya
import Alamofire

final class CoolNetworkKitTests: XCTestCase {
    var provider: Backend<MockAPI>!

    override func setUpWithError() throws {
        let session = NetworkSession.getNetworkSession(
            hostUrl: "https://example.com"
        )

        provider = Backend<MockAPI>(
            isStubbed: true,
            stubBehavior: .immediate,
            session: session
        )
    }

    override func tearDownWithError() throws {
        provider = nil
    }

    func testGetApiSuccessResult() async throws {
        let result = await provider.request(GeneralResponse.self, on: .mockGetSuccess)

        switch result {
        case .success(let response):
            XCTAssertTrue(response.isSuccess())
            XCTAssertEqual(response.getMessage(), "Request processed successfully")

        case .failure(let error, let errorMessage, let statusCode):
            XCTFail("Request failed: (\(statusCode)): \(errorMessage) \n\n \(error)")
        }
    }

    func testGetApiFailResult() async throws {
        let result = await provider.request(GeneralResponse.self, on: .mockGetFail)
        
        switch result {
        case .success(let response):
            XCTAssertFalse(response.isSuccess())
            XCTAssertEqual(response.getMessage(), "Request is failed")

        case .failure(let error, let errorMessage, let statusCode):
            XCTFail("Request failed: (\(statusCode)): \(errorMessage) \n\n \(error)")
        }
    }

    func testGetApiErrorResult() async throws {
        let result = await provider.request(GeneralResponse.self, on: .mockGetError)
        
        switch result {
        case .success(let response):
            if response.isSuccess() {
                XCTFail("Request should not succeed")
            } else {
                XCTFail("Request not success: \(response.getMessage())")
            }
            
        case .failure(let error, let errorMessage, let statusCode):
            print("Request failed: (\(statusCode)): \(errorMessage) \n\n \(error)")
            XCTAssertEqual(errorMessage, "Unauthenticated")
        }
    }

    func testHttpStatusCodeMessageForEmptyResponseOnApiFail() async throws {
        let result = await provider.request(GeneralResponse.self, on: .mockGetErrorWithNoData)
        
        switch result {
        case .success(let response):
            if response.isSuccess() {
                XCTFail("Request should not be get succeeded")
            } else {
                XCTFail("Request not success: \(response.getMessage())")
            }
            
        case .failure(let error, let errorMessage, let statusCode):
            print("Request failed: (\(statusCode)): \(errorMessage) \n\n \(error)")
            XCTAssertEqual(errorMessage, "(500) \(HttpStatusCode.getMessage(for: 500))")
        }
    }

    func testHttpStatusCodeMessageForUnparsableResponseOnApiFail() async throws {
        let result = await provider.request(GeneralResponse.self, on: .mockGetErrorWithNoData)

        switch result {
        case .success(let response):
            if response.isSuccess() {
                XCTFail("Request should not be get succeeded")
            } else {
                XCTFail("Request not success: \(response.getMessage())")
            }
            
        case .failure(let error, let errorMessage, let statusCode):
            print("Request failed: (\(statusCode)): \(errorMessage) \n\n \(error)")
            XCTAssertEqual(errorMessage, "(500) \(HttpStatusCode.getMessage(for: 500))")
        }
    }
}
