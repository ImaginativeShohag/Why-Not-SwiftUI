//: [Previous](@previous)

import Combine
import Foundation
import UIKit

/*:
 # Future and Promises

 - `Future` is a publisher that eventually produces a single value and then finishes or fails
 - a `Future` delivers exactly one value (or an error) and completes
 - ... it's a lightweight version of publishers, useful in contexts where you'd use a closure callback
 - ... allows you to call custom methods and return a `Result.success` or `Result.failure`
 */

//: ## Example 1

print("👉 Example 1")

//: We can replace a completion-handler closures...

func generateAsyncRandomNumber(completionHandler: @escaping (Int) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        let number = Int.random(in: 1 ... 10)
        completionHandler(number)
    }
}

generateAsyncRandomNumber { number in
    print("Got random number \(number). (From callback system)")
}

//: ...with Futures

func generateAsyncRandomNumberFromFuture() -> Future<Int, Never> {
    return Future { promise in
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let number = Int.random(in: 1 ... 10)
            promise(Result.success(number))
        }
    }
}

let cancellable = generateAsyncRandomNumberFromFuture()
    .sink { number in
        print("Got random number \(number). (From Future)")
    }

//: ----------------------------------------------------------------

//: ## Example 2

print("\n👉 Example 2")

struct User {
    let id: Int
    let name: String
}

let users = [User(id: 1, name: "Antoine"), User(id: 2, name: "Henk"), User(id: 3, name: "Bart")]

enum FetchError: Error {
    case userNotFound
}

func fetchUser(for userId: Int, completion: (_ result: Result<User, FetchError>) -> Void) {
    if let user = users.first(where: { $0.id == userId }) {
        completion(Result.success(user))
    } else {
        completion(Result.failure(FetchError.userNotFound))
    }
}

let fetchUserPublisher = PassthroughSubject<Int, FetchError>()

fetchUserPublisher
    .flatMap { userId -> Future<User, FetchError> in
        Future { promise in
            fetchUser(for: userId) { result in
                switch result {
                case .success(let user):
                    promise(.success(user))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
    }
    .map { user in user.name }
    .catch { error -> Just<String> in
        print("Error occurred: \(error)")
        return Just("Unknown")
    }
    .sink { result in
        print("User is \(result)")
    }

fetchUserPublisher.send(1)
fetchUserPublisher.send(5)

/*:
 # Further reading

 - [Future](https://developer.apple.com/documentation/combine/future)
 - [Using Combine for Your App’s Asynchronous Code](https://developer.apple.com/documentation/combine/using-combine-for-your-app-s-asynchronous-code)
 */

//: [Next](@next)
