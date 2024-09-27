//: [Previous](@previous)

import Foundation

/*:
 # Continuations
 
 "Continuation" is a mechanism to interface between synchronous and asynchronous code. It convert completion handlers into `async` functions.
 
 "Continuation" is a Swift concurrency feature that helps bridge asynchronous APIs (those using completion handlers) into Swift’s structured concurrency model, enabling you to work with `async`/`await`.
 
 ## `withCheckedContinuation` & `withCheckedThrowingContinuation`
 
 These variations ensures the compiler can verify that the continuation is resumed exactly once, which helps prevent certain common concurrency bugs.
 
 - `withCheckedContinuation` variation can't throw errors. So you can't use `continuation.resume(throwing:)` to resume the task.
 - `withCheckedThrowingContinuation` variant is for async functions that can throw errors. The closure provides a `CheckedContinuation<T, Error>`, allowing you to resume with either a value or an error.
 */

struct FlowersResponse: Decodable {
    let data: [Flower]
}

struct Flower: Decodable {
    let name: String
    let emoji: String
}

enum ApiError: Error {
    case responseError(Error?)
}

func fetchMessages(completion: @escaping (Result<[Flower], ApiError>) -> Void) {
    let url = URL(string: "https://raw.githubusercontent.com/ImaginativeShohag/Why-Not-SwiftUI/refs/heads/dev/raw/flowers.json")!

    URLSession.shared.dataTask(with: url) { data, _, error in
        if let data = data {
            if let response = try? JSONDecoder().decode(FlowersResponse.self, from: data) {
                completion(.success(response.data))
                return
            }
        }

        completion(.failure(.responseError(error)))
    }.resume()
}

func fetchMessages() async throws -> [Flower] {
    try await withCheckedThrowingContinuation { continuation in
        fetchMessages { result in
            switch result {
            case .success(let flowers):
                continuation.resume(returning: flowers)

            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}

let semaphore = DispatchSemaphore(value: 0)

Task {
    do {
        let messages = try await fetchMessages()
        print("Downloaded \(messages.count) flowers.")
    } catch {
        print("Error downloading flowers: \(error.localizedDescription).")
    }

    semaphore.signal()
}

semaphore.wait()

/*:
 # Other variations

 ## `withUnsafeContinuation` & `withUnsafeThrowingContinuation`

 These are “unsafe” versions that do not enforce compiler checks on the continuation, offering more flexibility but also a higher risk of errors like double or missed resumption.
 */

/*:
 # Further reading

 - [How to use continuations to convert completion handlers into async functions](https://www.hackingwithswift.com/quick-start/concurrency/how-to-use-continuations-to-convert-completion-handlers-into-async-functions)
 */

//: [Next](@next)
