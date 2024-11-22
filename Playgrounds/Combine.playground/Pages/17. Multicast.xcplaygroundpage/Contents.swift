//: [Previous](@previous)

import Combine
import Foundation

/*: # `multicast(_:)`

 Use a multicast publisher when you have multiple downstream subscribers, but you want upstream publishers to only process one receive(_:) call per event. This is useful when upstream publishers are doing expensive work you don’t want to duplicate, like performing network requests.

 The multicast publisher is a `ConnectablePublisher`, publishing only begins after a call to `connect()`.
 */

//: ## Example 1

//: A simple publisher that emits values 1, 2, and 3 with a delay
let publisher = (1 ... 3).publisher
    .delay(for: .seconds(2), scheduler: DispatchQueue.main)
    .print("Example 1 Publisher")

//: Create a multicast publisher using a `PassthroughSubject`
let multicastPublisher1 = publisher
    .multicast { PassthroughSubject<Int, Never>() }

//: First subscriber
let subscriber1 = multicastPublisher1
    .sink(receiveCompletion: { completion in
        print("Subscriber 1 completion: \(completion)")
    }, receiveValue: { value in
        print("Subscriber 1 received value: \(value)")
    })

//: Second subscriber
let subscriber2 = multicastPublisher1
    .sink(receiveCompletion: { completion in
        print("Subscriber 2 completion: \(completion)")
    }, receiveValue: { value in
        print("Subscriber 2 received value: \(value)")
    })

//: Connect the multicast publisher to start sending values to all subscribers
let cancellable = multicastPublisher1.connect()

/*: ## Example 2
 
 ### `Deferred`
 
 The `Deferred` publisher is used to **delay the creation of a publisher** until a subscriber actually subscribes to it. This is useful when you want the publisher’s work (like network calls or computations) to start only after a subscriber subscribes, not at the time of publisher creation.
 */

// Simulating a publisher that performs expensive work
let regularPublisher = Deferred {
    Future<Int, Never> { promise in
        print("Performing expensive work...")
        promise(.success(Int.random(in: 1 ... 100))) // Simulate different results
    }
}
.print("Example 2 Publisher")

print("Without multicast")

var cancellables = Set<AnyCancellable>()

// Subscriber 1
regularPublisher
    .sink { value in
        print("Subscriber 1 received: \(value)")
    }
    .store(in: &cancellables)

// Subscriber 2
regularPublisher
    .sink { value in
        print("Subscriber 2 received: \(value)")
    }
    .store(in: &cancellables)

print("")
print("With multicast")

// Multicasting the publisher to share the upstream work
let multicastPublisher2 = regularPublisher
    .multicast { PassthroughSubject<Int, Never>() }

// var cancellables = Set<AnyCancellable>()

// Subscriber 1
multicastPublisher2
    .sink { value in
        print("Subscriber 1 received: \(value)")
    }
    .store(in: &cancellables)

// Subscriber 2
multicastPublisher2
    .sink { value in
        print("Subscriber 2 received: \(value)")
    }
    .store(in: &cancellables)

// Connecting multicast publisher to trigger work
multicastPublisher2.connect()

/*:
 # Further reading

 - [multicast(_:)](https://developer.apple.com/documentation/combine/publisher/multicast(_:))
 - [Deferred](https://developer.apple.com/documentation/combine/deferred)
 */

//: [Next](@next)
