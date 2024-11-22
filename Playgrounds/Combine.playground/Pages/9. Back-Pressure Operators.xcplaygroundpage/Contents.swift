//: [Previous](@previous)

import Combine
import Foundation

/*:
 # Back-Pressure Operators
 */

/*:
 ## 1. buffer(size:prefetch:whenFull:)

 The buffer(size:prefetch:whenFull:) operator allows you to specify a buffer that holds a fixed number of items from the upstream publisher. You can specify what happens when the buffer is full: you can either drop old items or throw an error.
 */

let publisher1 = (1...10).publisher

let subscription1 = publisher1
    .buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)
    .sink(receiveCompletion: { print("Completed: \($0)") },
          receiveValue: { print("Received: \($0)") })

// Output:
// Received: 1
// Received: 2
// Received: 3
// Received: 4
// Received: 5
// Received: 6
// Received: 7
// Received: 8
// Received: 9
// Received: 10
// Completed: finished

/*:
 Explanation:

 In this example, buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest) specifies that the buffer can hold up to 5 items, but when it’s full, it will drop the oldest item to accommodate new ones. You could also use .dropNewest to drop the latest incoming value or .customError to throw an error when the buffer is full.
 */

/*:
 ## 2. debounce(for:scheduler:options:)

 The debounce(for:scheduler:options:) operator emits a value only after the upstream publisher has stopped sending values for the specified time interval.
 */

let subject2 = PassthroughSubject<Int, Never>()
let subscription2 = subject2
    .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
    .sink(receiveValue: { print("Received: \($0)") })

subject2.send(1)
subject2.send(2)
subject2.send(3)

// After a 1-second pause:
DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
    subject2.send(4)
}

// Output:
// Received: 3
// Received: 4

/*:
 Explanation:

 Here, debounce(for: .seconds(1.0), scheduler: RunLoop.main) means that it will wait until there’s a 1-second pause in publishing before it sends the latest value downstream. Only 3 and 4 get published, as they’re the last values before each 1-second delay.
 */

/*:
 ## 3. throttle(for:scheduler:latest:)

 The throttle(for:scheduler:latest:) operator limits the number of elements sent downstream to one per specified interval, depending on the latest parameter.
 */

let subject3 = PassthroughSubject<Int, Never>()
let subscription3 = subject3
    .throttle(for: .seconds(1.0), scheduler: RunLoop.main, latest: true)
    .sink(receiveValue: { print("Received: \($0)") })

subject3.send(1)
subject3.send(2)
subject3.send(3)

// After a 1-second pause:
DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
    subject3.send(4)
    subject3.send(5)
}

// Output:
// Received: 3
// Received: 5

/*:
 Explanation:

 With throttle(for: .seconds(1.0), scheduler: RunLoop.main, latest: true), this example only sends the latest item within each 1-second interval. So, only 3 and 5 are published. If latest were false, it would publish the first item within each interval instead.
 */

/*
 ## 4. collect(_:) and collect(_:options:)

 The collect(_:) operator groups a specified number of values and sends them as an array, while collect(_:options:) can also apply a time interval, sending an array if the buffer is full or after a given time.

 collect(_:) example:
 */

let publisher4 = (1...10).publisher

let subscription4 = publisher4
    .collect(3)
    .sink(receiveValue: { print("Received array: \($0)") })

// Output:
// Received array: [1, 2, 3]
// Received array: [4, 5, 6]
// Received array: [7, 8, 9]
// Received array: [10]

/*:
 Explanation:

 In this case, collect(3) groups elements into arrays of 3 and sends them downstream. The final batch only contains 10, as there were not enough elements left to fill an array of 3.

 collect(_:options:) example with time interval:
 */

let subject5 = PassthroughSubject<Int, Never>()

let subscription5 = subject5
    .collect(3, options: .byTime(RunLoop.main, .seconds(1.5)))
    .sink(receiveValue: { print("Received array: \($0)") })

subject5.send(1)
subject5.send(2)
subject5.send(3)

// After 1.5 seconds:
DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
    subject5.send(4)
    subject5.send(5)
}

// Output:
// Received array: [1, 2, 3]
// Received array: [4, 5]

/*:
 Explanation:

 Here, collect(3, options: .byTime(RunLoop.main, .seconds(1.5))) creates an array of up to 3 items or sends whatever items are in the buffer every 1.5 seconds. The first array is sent when 3 items are received, and the second one is sent after 1.5 seconds.
 */

//: [Next](@next)
