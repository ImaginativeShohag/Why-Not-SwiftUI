//: [Previous](@previous)

import Foundation

/*:
 # Data race - solution

 To avoid the race condition, we need to synchronize access to the shared resource (value). One way to do this is by using a serial queue or a lock:
 */

class Counter {
    private var value = 0
    private let queue = DispatchQueue(label: "counter.queue") // Serial queue

    func increment() {
        queue.sync {
            value += 1
        }
    }

    func getValue() -> Int {
        return queue.sync { value }
    }
}

let counter = Counter()

DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    counter.increment()
}

print("Final counter value: \(counter.getValue())")

//: [Next](@next)
