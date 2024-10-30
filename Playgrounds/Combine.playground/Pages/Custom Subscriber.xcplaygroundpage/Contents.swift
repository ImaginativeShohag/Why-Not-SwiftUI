//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

// This is necessary for the Playgrounds app. This enables indefinite execution, which is necessary for this page.
PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 # Custom Subscriber

 A `Subscriber` instance receives a stream of elements from a `Publisher`, along with life cycle events describing changes to their relationship.
 */

//: Publisher: Uses a timer to emit the date once per second.
let timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    // Auto connect the publisher to the subscriber as soon as the subscriber attached to the publisher.
    .autoconnect()

//: Subscriber: Waits 5 seconds after subscription, then requests a maximum of 3 values.
class MySubscriber: Subscriber {
    typealias Input = Date
    typealias Failure = Never
    var subscription: Subscription?

    func receive(subscription: Subscription) {
        print("Received subscription at \(Date())")
        self.subscription = subscription

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // Publisher will not publish unless demand is requested.
            subscription.request(.max(3))
        }
    }

    func receive(_ input: Date) -> Subscribers.Demand {
        print("Received Data: \(input)")
        return Subscribers.Demand.none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("Received completion: \(completion)")
    }
}

//: Subscribe
let subscriber = MySubscriber()
timerPublisher.subscribe(subscriber)

//: Force stop receiving
DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    subscriber.receive(completion: .finished)
}

/*:
 # Further reading

 - [Subscriber](https://developer.apple.com/documentation/combine/subscriber)
 */

//: [Next](@next)
