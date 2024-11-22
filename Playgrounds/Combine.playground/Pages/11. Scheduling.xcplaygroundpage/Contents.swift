//: [Previous](@previous)

import Combine
import Foundation

/*:
 # Scheduling operators

 - Combine introduces the `Scheduler` protocol
 - ... adopted by `DispatchQueue`, `RunLoop` and others
 - ... lets you determine the execution context for subscription and value delivery
 */

/// A semaphore used to signal completion of the first step in the operation.
///
/// - Note: `firstStepDone` is initialized with a value of `0`, meaning that `wait()` will block
///         until `signal()` is called. This is used to control the flow of asynchronous code in the example,
///         ensuring that the main thread waits for all expected values to be received before proceeding.
let firstStepDone = DispatchSemaphore(value: 0)

/// A counter that tracks the number of values received from the `publisher`.
///
/// - Note: `count` is incremented each time a value is received in the `sink` subscriber.
///         When `count` reaches 4, the `firstStepDone` semaphore is signaled, allowing
///         the main thread to proceed. This ensures that exactly four values have been processed.
var count = 0

/*:
 ## `receive(on:)`

 - determines on which scheduler values will be received by the next operator and then on
 - used with a `DispatchQueue`, lets you control on which queue values are being delivered
 */
print("* Demonstrating receive(on:)")

let publisher = PassthroughSubject<String, Never>()
let receivingQueue = DispatchQueue(label: "receiving-queue")
let subscription = publisher
    .receive(on: receivingQueue)
    .sink { value in
        print("Received value: \(value) on thread \(Thread.current)")
        
        // Check to unlock the main thread.
        count += 1
        if count == 4 {
            firstStepDone.signal()
        }
    }

for string in ["One", "Two", "Three", "Four"] {
    DispatchQueue.global().async {
        publisher.send(string)
    }
}

// Lock the main thread.
firstStepDone.wait()

/*:
 ## `subscribe(on:)`

 - determines on which scheduler the subscription occurs
 - useful to control on which scheduler the work _starts_
 - may or may not impact the queue on which values are delivered
 */
print("\n* Demonstrating subscribe(on:)")

let subscription2 = [1, 2, 3, 4, 5].publisher
    .subscribe(on: DispatchQueue.global())
    .handleEvents(receiveOutput: { value in
        print("Value \(value) emitted on thread \(Thread.current)")
    })
    .receive(on: receivingQueue)
    .sink { value in
        print("Received value: \(value) on thread \(Thread.current)")
    }

//: [Next](@next)
