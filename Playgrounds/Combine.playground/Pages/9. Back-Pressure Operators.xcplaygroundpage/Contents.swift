//: [Previous](@previous)

import Combine
import Foundation

/*:
 # Back-Pressure Operators
 */

/*:
 ## 1. `buffer(size:prefetch:whenFull:)`

 This operator allows you to specify a buffer that holds a fixed number of items from the upstream publisher. You can specify what happens when the buffer is full: you can either drop old items or throw an error.
 */

let publisher1 = (1...10).publisher

let subscription1 = publisher1
    .buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)
    .sink(receiveCompletion: { print("(Publisher 1) Completed: \($0)") },
          receiveValue: { print("(Publisher 1) Received: \($0)") })

/*:
 Explanation:

 In this example, `buffer(size: 5, prefetch: .byRequest, whenFull: .dropOldest)` specifies that the buffer can hold up to 5 items, but when it’s full, it will drop the oldest item to accommodate new ones. You could also use `.dropNewest` to drop the latest incoming value or `.customError` to throw an error when the buffer is full.
 */

//: ----------------------------------------------------------------

/*:
 ## 2. `debounce(for:scheduler:options:)`

 This operator emits a value only after the upstream publisher has stopped sending values for the specified time interval.
 */

let bounces:[(Int,TimeInterval)] = [
    (0, 0),
    (1, 0.25),  // 0.25s interval since last index
    (2, 1),     // 0.75s interval since last index
    (3, 1.25),  // 0.25s interval since last index
    (4, 1.5),   // 0.25s interval since last index
    (5, 2)      // 0.5s interval since last index
]

let publisher2 = PassthroughSubject<Int, Never>()
let subscription2 = publisher2
    .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
    .sink { index in
        print ("(Publisher 2) Received index \(index)")
    }

for bounce in bounces {
    DispatchQueue.main.asyncAfter(deadline: .now() + bounce.1) {
        publisher2.send(bounce.0)
    }
}

/*:
 Explanation:
 
 Here is the event flow shown from the perspective of time, showing value delivery through the `debounce()` operator:

 Time 0: Send index 0. Countdown ⏱️ started.
 Time 0.25: Send index 1. Again countdown ⏱️ started. Index 0 was waiting and is discarded 🗑️.
 Time 0.75: Debounce period ends, publish index 1.
 Time 1: Send index 2. Again countdown ⏱️ started.
 Time 1.25: Send index 3. Again countdown ⏱️ started. Index 2 was waiting and is discarded 🗑️.
 Time 1.5: Send index 4. Again countdown ⏱️ started. Index 3 was waiting and is discarded 🗑️.
 Time 2: Debounce period ends, publish index 4. Also, send index 5. Again countdown ⏱️ started.
 Time 2.5: Debounce period ends, publish index 5.
 */

//: ----------------------------------------------------------------

/*:
 ## 3. `throttle(for:scheduler:latest:)`

 This operator limits the number of elements sent downstream to one per specified interval, depending on the latest parameter.
 */

let publisher3 = PassthroughSubject<Int, Never>()
let subscription3 = publisher3
    .throttle(for: .seconds(1.0), scheduler: RunLoop.main, latest: true)
    .sink(receiveValue: { print("(Publisher 3) Received: \($0)") })

publisher3.send(1)
publisher3.send(2)
publisher3.send(3)

//: After a 1-second pause:
DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
    publisher3.send(4)
    publisher3.send(5)
    publisher3.send(6)
}

/*:
 Explanation:

 With `throttle(for: .seconds(1.0), scheduler: RunLoop.main, latest: true)`, this example only sends the latest item within each 1-second interval. So, only 3 and 6 are published. If latest were false, it would publish the first item within each interval instead.
 */

//: ----------------------------------------------------------------

/*:
 ## 4. `collect(_:)` and collect(_:options:)

 The collect(_:) operator groups a specified number of values and sends them as an array, while collect(_:options:) can also apply a time interval, sending an array if the buffer is full or after a given time.

 ### `collect(_:)` example
 */

let publisher4 = (1...10).publisher

let subscription4 = publisher4
    .collect(3)
    .sink(receiveValue: { print("(Publisher 4) Received array: \($0)") })

// Output:
// Received array: [1, 2, 3]
// Received array: [4, 5, 6]
// Received array: [7, 8, 9]
// Received array: [10]

/*:
 Explanation:

 In this case, collect(3) groups elements into arrays of 3 and sends them downstream. The final batch only contains 10, as there were not enough elements left to fill an array of 3.

 ### `collect(_:options:)` example
 */

let subject5 = PassthroughSubject<Int, Never>()

let subscription5 = subject5
    .collect(.byTimeOrCount(RunLoop.main, .seconds(1.5), 3))
    .sink(receiveValue: { print("(Publisher 5) Received array: \($0)") })

subject5.send(1)
subject5.send(2)
subject5.send(3)

//: After 1.5 seconds:
DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
    subject5.send(4)
    subject5.send(5)
}

// Output:
// Received array: [1, 2, 3]
// Received array: [4, 5]

/*:
 Explanation:

 Here, `collect(.byTimeOrCount(RunLoop.main, .seconds(1.5), 3))` creates an array of up to 3 items or sends whatever items are in the buffer every 1.5 seconds. The first array is sent when 3 items are received, and the second one is sent after 1.5 seconds.
 */

//: [Next](@next)
