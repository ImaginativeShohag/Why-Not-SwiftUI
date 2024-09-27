//: [Previous](@previous)

import Foundation

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
 # Further reading

 - [How to use continuations to convert completion handlers into async functions](https://www.hackingwithswift.com/quick-start/concurrency/how-to-use-continuations-to-convert-completion-handlers-into-async-functions)
 */

//: [Next](@next)
