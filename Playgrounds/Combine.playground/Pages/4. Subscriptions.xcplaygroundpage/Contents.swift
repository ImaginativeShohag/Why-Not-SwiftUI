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
let subscriber1 = subject.handleEvents(
    receiveSubscription: { _ in
        print("⚡️ Event: New subscription!")
    },
    receiveOutput: { _ in
        print("⚡️ Event: Received new value!")
    },
    receiveCompletion: { completion in
        print("⚡️ Event: A subscription completed with \(completion)")
    },
    receiveCancel: {
        print("⚡️ Event: A subscription cancelled")
    },
    receiveRequest: { demand in
        print("⚡️ Event: received demand: \(demand.description)")
    }
)
//: Replaces any errors in the stream with the provided element.
.replaceError(with: "Failure")
.sink { value in
    print("Subscriber 1 received value: \(value)")
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
 */

let subscriber2 = subject.sink { completion in
    print("Subscriber 2 received completion: \(completion)")
} receiveValue: { value in
    print("Subscriber 2 received value: \(value)")
}

//: ⚠️ Note: Comment out `send(completion: .failure(...)` code and try the following code to try "cancel" event.

// subscriber1.cancel()
// subject.send("Hello?? :(")

//: The `cancel()` will cancel the `subscriber1` and won't affect `subscriber2`.

//: [Next](@next)
