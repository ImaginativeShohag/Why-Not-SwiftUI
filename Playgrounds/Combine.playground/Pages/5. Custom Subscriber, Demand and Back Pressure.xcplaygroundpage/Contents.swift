//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

// This is necessary for the Playgrounds app. This enables indefinite execution, which is necessary for this page.
PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 # Custom Subscriber, Demand and Back Pressure

 A `Subscriber` instance receives a stream of elements from a `Publisher`, along with life cycle events describing changes to their relationship.

 In Combine, a `Publisher` produces elements, and a `Subscriber` acts on the elements it receives.

 - A publisher can’t send elements until the subscriber attaches and asks for them.
 - The subscriber also controls the rate at which the publisher delivers elements, by using the `Subscribers.Demand` type to indicate how many elements it can receive.
 - A subscriber can indicate demand in either of two ways:
    - By calling `request(_:)` on the `Subscription` instance that the publisher provided when the subscriber first subscribed.
    - By returning a new demand when the publisher calls the subscriber’s `receive(_:)` method to deliver an element.
 - `Demand` is a requested number of items, sent to a publisher from a subscriber through the subscription.
 - `Demand` is additive: : If a subscriber has demanded two elements, and then requests Subscribers.Demand(.max(3)), the publisher’s unsatisfied demand is now five elements. If the publisher then sends an element, the unsatisfied demand decreases to four.
    - Publishing elements is the only way to reduce unsatisfied demand; subscribers can’t request negative demand.

 To control the rate at which the publisher sends elements to your subscriber, create a custom implementation of the Subscriber protocol. Use your implementation to specify demands that you know your subscriber can keep up with. As the subscriber receives elements, it can request more by returning a new demand value to `receive(_:)`, or by calling `request(_:)` on the subscription. With either, your subscriber can then fine-tune the number of elements the publisher can send it at any given time.

 This concept of controlling flow by signaling a subscriber’s readiness to receive elements is called **back pressure**.
 */

/*:
 ## Example with unlimited demand

 `.sink` subscriber also has unlimited demand.
 */

let publisher1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].publisher

class SimpleSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never

    let TAG = "SimpleSubscriber"

    func receive(subscription: any Subscription) {
        print("\(TAG) Received subscription!")

        subscription.request(.unlimited)
    }

    func receive(_ input: Int) -> Subscribers.Demand {
        print("\(TAG) Received data: \(input)")
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("\(TAG) Received completion: \(completion)")
    }
}

//: Subscribe
let simpleSubscriber = SimpleSubscriber()
publisher1.subscribe(simpleSubscriber)

/*:
 ## Apply Back Pressure with a Custom Subscriber

 Each publisher keeps track of its current unsatisfied demand, meaning how many more elements a subscriber has requested. Even automated sources like Foundation’s `Timer.TimerPublisher` only produce elements when they have pending demand. The following example code illustrates this behavior.
 */

//: Publisher: Uses a timer to emit the date once per second.
let timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    // Auto connect the publisher to the subscriber as soon as the subscriber attached to the publisher.
    .autoconnect()

//: Subscriber: Waits 5 seconds after subscription, then requests a maximum of 3 values.
class LimitedDemandSubscriber: Subscriber {
    typealias Input = Date
    typealias Failure = Never

    let TAG = "LimitedDemandSubscriber"

    var subscription: Subscription?

    func receive(subscription: Subscription) {
        print("\(TAG) Received subscription at \(Date())")
        self.subscription = subscription
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            subscription.request(.max(3))
        }
    }

    func receive(_ input: Date) -> Subscribers.Demand {
        print("\(TAG) Received Data: \(input)")
        return Subscribers.Demand.none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("\(TAG) Received completion: \(completion)")
    }
}

//: Subscribe
let limitedDemandSubscriber = LimitedDemandSubscriber()
print("Subscribing at \(Date())")
timerPublisher.subscribe(limitedDemandSubscriber)

/*:
 ## Example for additive `Demand` demonstration
 */

/*:
 Subscriber: Start demand with 5 item, and for each item receive, request for 2 more item. After 10 seconds it will stop requesting new demand.

 So total item will be received:

 - Initial demand is 5
 - The timer will send item after every 1 seconds
 - For first 10 seconds, subscriber will demand 2 items and after that it will demand 0 item
 - After first 10 seconds subscriber will receive 9 items
 - Every 9 item will demand 2 items, so total -> 9 * 2 = 18 demands

 So, total demand is 5 + 18 = 23, means total 23 items will be received by the following subscriber.
 */
class AdditiveDemandSubscriber: Subscriber {
    typealias Input = Date
    typealias Failure = Never

    let TAG = "AdditiveDemandSubscriber"

    var subscription: Subscription?

    var counter = 1
    var targetDate: Date? = nil

    func receive(subscription: Subscription) {
        print("\(TAG) Received subscription at \(Date())")

        // Will stop the demand requesting after 10 seconds.
        targetDate = Date().addingTimeInterval(10)

        self.subscription = subscription

        // Initial demand is 5
        subscription.request(.max(5))
    }

    func receive(_ input: Date) -> Subscribers.Demand {
        let currentCount = counter
        counter += 1

        print("\n\(TAG) Received Data: (item \(currentCount)) \(input)")

        // Stop demand requesting after 10 seconds.
        if targetDate! <= input {
            print("\(TAG) Requesting demand (after \(currentCount) seconds): 0")
            return .none
        }

        // Requesting demand: 2 more item
        print("\(TAG) Requesting demand (after \(currentCount) seconds): 2")
        return .max(2)
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("\(TAG) Received completion: \(completion)")
    }
}

//: Subscribe
let additiveDemandSubscriber = AdditiveDemandSubscriber()
timerPublisher.subscribe(additiveDemandSubscriber)

/*:
 ### Stop receiving

 To stop receiving we can use the `cancel()` method of the subscription.

 ⚠️ Uncomment the following code to stop the subscriber after 5 seconds.
 */

// DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//    additiveDemandSubscriber.subscription?.cancel()
// }

/*:
 # Further reading

 - [Subscriber](https://developer.apple.com/documentation/combine/subscriber)
 - [Processing Published Elements with Subscribers](https://developer.apple.com/documentation/combine/processing-published-elements-with-subscribers)
 - [A possible implementation of the `sink` method](https://stackoverflow.com/a/69922582/2263329)
 */

//: [Next](@next)
