//: [Previous](@previous)

import Combine
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 # Connectable Publishers

 Coordinate when publishers start sending elements to subscribers.
 */

/*:
 ## `makeConnectable()`

 We can make any publisher connectable using `makeConnectable()` method.
 */

let url = URL(string: "https://example.com/")!
let connectable = URLSession.shared
    .dataTaskPublisher(for: url)
    .map { $0.data }
    .catch { _ in Just(Data()) }
    .share()
    .makeConnectable()

let cancellable1 = connectable
    .sink(
        receiveCompletion: { print("Received completion 1: \($0).") },
        receiveValue: { print("Received data 1: \($0.count) bytes.") }
    )

var cancellable2: AnyCancellable?
var connection: (any Cancellable)?

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    cancellable2 = connectable
        .sink(
            receiveCompletion: { print("Received completion 2: \($0).") },
            receiveValue: { print("Received data 2: \($0.count) bytes.") }
        )
}

//: Publisher will produce elements after we call `connect()`.

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    connection = connectable.connect()
}

/*:
 ## `autoconnect()`

 Automates the process of connecting or disconnecting from this connectable publisher.
 */

let timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    .autoconnect()

let timerSubscriptionCancellable = timerPublisher.sink { date in
    print("Date now: \(date)")
}

Task {
    try? await Task.sleep(for: .seconds(5))

    timerSubscriptionCancellable.cancel()
}

/*:
 # Further reading

 - [Controlling Publishing with Connectable Publishers](https://developer.apple.com/documentation/combine/controlling-publishing-with-connectable-publishers)
 - [publish(every:tolerance:on:in:options:)](https://developer.apple.com/documentation/foundation/timer/3329589-publish)
 */

//: [Next](@next)
