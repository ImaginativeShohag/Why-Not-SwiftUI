//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Combine
import CombineMoya
import Foundation
import Moya
import SuperLog

/// This is a subclass of `MoyaProvider`. This is the heart for API call.
///
/// This class serves as the core for making API calls.
///
/// - Parameter API: The generic type representing the API endpoints conforming to ApiEndpoint.
///
/// - Note: Tested with `BackendTest`.
public class Backend<API>: MoyaProvider<API> where API: ApiEndpoint {
    private let onError: (_ route: String, _ code: Int) -> ()

    /// Initializes the provider for network calls.
    ///
    /// - Parameters:
    ///   - isStubbed: A boolean value to indicate if the responses will be stubbed.
    ///   - stubBehavior: Explains the stub behavior. Default is set to `.delayed(seconds: 1)`.
    ///   - session: Underlying `URLSession` for this instance.
    ///   - onError: A callback closure with `route` and `statusCode` in parameter. It will be executed when the network call fails.
    public init(
        isStubbed: Bool = false,
        stubBehavior: StubBehavior = .delayed(seconds: 1),
        session: Session,
        onError: @escaping (_ route: String, _ code: Int) -> () = { _, _ in }
    ) {
        var plugins: [PluginType] = [
            MoyaCacheablePlugin()
        ]

        self.onError = onError

        #if DEBUG
        plugins.append(NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)))
        #endif

        super.init(
            endpointClosure: { target in
                Endpoint(
                    url: URL(target: target).absoluteString,
                    sampleResponseClosure: {
                        .networkResponse(
                            target.stubStatusCode,
                            target.sampleData
                        )
                    },
                    method: target.method,
                    task: target.task,
                    httpHeaderFields: target.headers
                )
            },
            stubClosure: { _ in isStubbed ? stubBehavior : .never },
            callbackQueue: DispatchQueue(label: API.dispatchLabel),
            session: session,
            plugins: plugins
        )
    }
}

// MARK: - Extensions

public extension Backend {
    static func canceledRequestResult<T: Decodable>() -> ApiResult<T> {
        return .failure(
            error: MoyaError.underlying(AsyncError.requestCancelled, nil),
            errorMessage: "Request cancelled!",
            statusCode: -1
        )
    }

    /// Request for an API call to the `endpoint` for a `resourceType` response.
    func request<T>(
        _ resourceType: T.Type,
        on endpoint: API
    ) async -> ApiResult<T> where T: Decodable {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            // ----------------------------------------------------------------
            // Check task cancellation
            // ----------------------------------------------------------------
            if _Concurrency.Task.isCancelled {
                continuation.resume(returning: Backend.canceledRequestResult())
                cancellable?.cancel()
                return
            }
            // ----------------------------------------------------------------

            cancellable = requestPublisher(endpoint)
                .filterSuccessfulStatusCodes()
                .map(T.self)
                .eraseToAnyPublisher()
                .receive(on: DispatchQueue.main)
                .sink { status in
                    switch status {
                    case .finished:
                        SuperLog.v("finished")

                    case let .failure(error):
                        SuperLog.v("failed: \(error)")

                        let statusCode: Int = error.response?.statusCode ?? -1

                        DispatchQueue.main.async {
                            self.onError(endpoint.path, statusCode)
                        }

                        // ----------------------------------------------------------------
                        // Handle `Empty` model
                        // ----------------------------------------------------------------

                        /// If the status code is between success codes and the`responseType` is given `Empty.self`, then we will call the compilation closure manually.
                        if resourceType is Alamofire.Empty.Type, (200 ... 299).contains(statusCode) {
                            // ----------------------------------------------------------------
                            // Check task cancellation
                            // ----------------------------------------------------------------
                            if _Concurrency.Task.isCancelled {
                                continuation.resume(returning: Backend.canceledRequestResult())
                                cancellable?.cancel()
                                return
                            }
                            // ----------------------------------------------------------------

                            continuation.resume(returning: .success(response: Alamofire.Empty.value as! T))
                            return
                        }

                        // ----------------------------------------------------------------
                        // Error message generation
                        // ----------------------------------------------------------------

                        var errorMessage = ""

                        #if PRODUCTION
                        if case let .statusCode(response) = error {
                            /// If the app is in **production** we only show status code related messages.
                            errorMessage = HttpStatusCode.getMessage(for: response.statusCode)

                            if statusCode > 0 {
                                errorMessage = "(\(statusCode)) \(errorMessage)"
                            }
                        } else {
                            /// If the app is in **production** and the error is **not related** to **status code** then we show this.
                            errorMessage = "Something went wrong. Please try again."
                        }
                        #else

                        errorMessage = self.getErrorMessage(for: error)

                        if statusCode > 0 {
                            errorMessage = "(\(statusCode)) \(errorMessage)"
                        }
                        #endif

                        // ----------------------------------------------------------------
                        // For parsing error
                        // ----------------------------------------------------------------

                        if (200 ... 299).contains(statusCode), case .objectMapping = error {
                            errorMessage = "Invalid server response. Please try again."
                        }

                        // ----------------------------------------------------------------
                        // Try to parse the error message from response
                        // ----------------------------------------------------------------

                        /// In **production** we will not show server given errors.
                        else if let parsedErrorMessage = self.parseResponseErrorMessage(from: error) {
                            #if !PRODUCTION
                            errorMessage = parsedErrorMessage
                            #endif
                        }

                        // ----------------------------------------------------------------
                        // Check task cancellation
                        // ----------------------------------------------------------------
                        if _Concurrency.Task.isCancelled {
                            continuation.resume(returning: Backend.canceledRequestResult())
                            cancellable?.cancel()
                            return
                        }
                        // ----------------------------------------------------------------
                        continuation.resume(returning: .failure(
                            error: error,
                            errorMessage: errorMessage,
                            statusCode: statusCode
                        ))
                    }

                    cancellable?.cancel()
                } receiveValue: { response in
                    // ----------------------------------------------------------------
                    // Check task cancellation
                    // ----------------------------------------------------------------
                    if _Concurrency.Task.isCancelled {
                        continuation.resume(returning: Backend.canceledRequestResult())
                        cancellable?.cancel()
                        return
                    }
                    // ----------------------------------------------------------------

                    continuation.resume(returning: .success(response: response))
                }
        }
    }

    /// - Returns: Parsed error from the error response from server. Otherwise empty `String`.
    private func parseResponseErrorMessage(from error: MoyaError) -> String? {
        if let data = error.response?.data, let json = String(data: data, encoding: .utf8) {
            SuperLog.v("decoded json: \(json)")

            do {
                let errorResponse = try JSONDecoder().decode(
                    GeneralResponse.self,
                    from: data
                )
                return errorResponse.getMessage()
            } catch {
                SuperLog.v(error)
            }
        }

        return nil
    }

    /// - Returns: Parsed error message from the `MoyaError`.
    private func getErrorMessage(for error: MoyaError) -> String {
        switch error {
        case let .statusCode(response):
            return HttpStatusCode.getMessage(for: response.statusCode)

        case let .underlying(error, _):
            if let afError = error as? AFError,
               case let .sessionTaskFailed(underlyingError) = afError
            {
                return underlyingError.localizedDescription
            } else {
                return error.localizedDescription
            }

        default:
            return error.localizedDescription
        }
    }
}

public enum AsyncError: Error {
    case requestCancelled
}

#if DEBUG

extension Backend {
    func public_parseResponseErrorMessage(from error: MoyaError) -> String? {
        parseResponseErrorMessage(from: error)
    }

    func public_getErrorMessage(for error: MoyaError) -> String {
        getErrorMessage(for: error)
    }
}

#endif
