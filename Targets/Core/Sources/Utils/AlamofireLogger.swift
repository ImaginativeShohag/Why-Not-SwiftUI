//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Alamofire
import Foundation

/// A network logger for `Alamofire`.
///
/// Example:
///
/// ```swift
/// let session = Session(
///     eventMonitors: [AlamofireLogger()]
/// )
/// ```
final class AlamofireLogger: EventMonitor {
    func requestDidResume(_ request: Request) {
        queue.async {
            guard let request = request.request else { return }

            let httpMethod = request.httpMethod ?? ""
            let url = request.url?.absoluteString ?? ""
            let headers = request.headers
            let httpBody = request.httpBody

            print("================================ >>>")

            print("\(httpMethod) '\(url)'")

            if !headers.isEmpty {
                self.logHeaders(headers: headers)
            }

            if let httpBody = httpBody, let parameters = String(data: httpBody, encoding: .utf8) {
                print("Parameters: \(parameters)")
            }

            print("================================ >>>")
        }
    }

    func requestDidFinish(_ request: Request) {
        queue.async {
            guard let dataRequest = request as? DataRequest,
                  let task = dataRequest.task,
                  let metrics = dataRequest.metrics,
                  let request = task.originalRequest,
                  let httpMethod = request.httpMethod,
                  let requestURL = request.url
            else {
                return
            }

            let elapsedTime = metrics.taskInterval.duration

            print("<<< ================================")

            if let error = task.error {
                print("[Error] \(httpMethod) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]")

                print(error)
            } else {
                guard let response = task.response as? HTTPURLResponse else {
                    return
                }

                print("\(httpMethod) \(String(response.statusCode)) '\(requestURL.absoluteString)' [\(String(format: "%.04f", elapsedTime)) s]")

                self.logHeaders(headers: response.allHeaderFields)

                guard let data = dataRequest.data else { return }

                print("Body:")

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

                    if let prettyString = String(data: prettyData, encoding: .utf8) {
                        print(prettyString)
                    }
                } catch {
                    if let string = String(data: data, encoding: String.Encoding.utf8) {
                        print(string)
                    }
                }
            }

            print("<<< ================================")
        }
    }

    func logHeaders(headers: [AnyHashable: Any]) {
        print("Headers: [")
        for (key, value) in headers {
            print("  \(key): \(value)")
        }
        print("]")
    }

    func logHeaders(headers: HTTPHeaders) {
        print("Headers: [")
        for header in headers {
            print("  \(header.name): \(header.value)")
        }
        print("]")
    }
}
