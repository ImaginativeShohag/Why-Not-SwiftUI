//: [Previous](@previous)

import Combine
import UIKit

/*:
 ## Subscription details

 - A subscriber will receive a _single_ subscription
 - _Zero_ or _more_ values can be published
 - At most _one_ {completion, error} will be called
 - After completion, nothing more is received
 */

enum ExampleError: Swift.Error {
    case somethingWentWrong
}

let subject = PassthroughSubject<String, ExampleError>()

/*:
 The `handleEvents` operator lets you intercept all stages of a subscription lifecycle.
 */
let cancellable = subject.handleEvents(
    receiveSubscription: { _ in
        print("New subscription!")
    },
    receiveOutput: { _ in
        print("Received new value!")
    },
    receiveCompletion: { _ in
        print("A subscription completed")
    },
    receiveCancel: {
        print("A subscription cancelled")
    }
)
//: Replaces any errors in the stream with the provided element.
.replaceError(with: "Failure")
.sink { value in
    print("Subscriber received value: \(value)")
}

subject.send("Hello!")
subject.send("Hello again!")
subject.send("Hello for the last time!")

/*:
 ## Check failure
 */

subject.send(completion: .failure(.somethingWentWrong))
subject.send("Hello?? :(")

/*:
 ## Check cancellable

 Comment out `send(completion: .failure(...)` code and try the following code to try cancel event.
 */

cancellable.cancel()
subject.send("Hello?? :(")

//:
//: [Next](@next)
