//: [Previous](@previous)

import Combine
import Foundation

/*:
 # Subjects

 - A subject is a publisher ...
 - ... relays values it receives from other publishers ...
 - ... can be manually fed with new values
 - ... subjects are also subscribers, and can be used with `subscribe(_:)`
 - Unlike typical publishers (which are cold ❄️), subjects are **hot** 🔥: they can start emitting values even before a subscriber attaches, and any new subscriber may miss previously emitted values.
 */

/*:
 ## Example 1

 Using a subject to relay values to subscribers
 */

let relay = PassthroughSubject<String, Never>()

let subscription1 = relay
    .sink { _ in
        print("subscription1 completed")
    } receiveValue: { value in
        print("subscription1 received value: \(value)")
    }

relay.send("Hello")
relay.send("World!")

//: What happens if you send "hello" before setting up the subscription?

relay.send("Hello")

let subscriptionAfterSend = relay
    .sink { value in
        print("subscriptionAfterSend received value: \(value)")
    }

relay.send("World!")

/*:
 ## Example 2

 Subscribing a subject to a publisher
 */

let publisher = ["Here", "we", "go!"].publisher

publisher.subscribe(relay)

//: This will not work. Because after calling `publisher.subscribe(relay)`, the `PassthroughSubject` (`relay`) becomes a downstream subscriber of publisher.
relay.send("Final Value!")

/*:
 ## Example 3

 Using a `CurrentValueSubject` to hold and relay the latest value to new subscribers
 */

let variable = CurrentValueSubject<String, Never>("")

variable.send("Initial text")
variable.send("Another initial text")

let subscription2 = variable.sink { _ in
    print("subscription2 completed")
} receiveValue: { value in
    print("subscription2 received value: \(value)")
}

variable.send("More text")

/*:
 ## Send completion signal to subscriber
 */

//: Run the code once then uncomment the below code and run again to see the effect.
variable.send(completion: .finished)

variable.send("Another more text")

//: [Next](@next)
