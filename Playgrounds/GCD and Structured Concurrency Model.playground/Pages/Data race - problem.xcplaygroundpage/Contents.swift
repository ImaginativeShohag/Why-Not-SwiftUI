//: [Previous](@previous)

import Foundation

/*:
 # What is Data Race?

 A data race can occur when multiple threads access the same memory without synchronization and at least one access is a write. You could be reading values from an array from the main thread while a background thread is adding new values to that same array.
 */

class Counter {
    var value = 0
    
    func increment() {
        value += 1
    }
}

let counter = Counter()

// Dispatching 1000 increments concurrently
DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    counter.increment() // Accessing the shared resource 'value'
}

print("Final counter value: \(counter.value)")

//: [Next](@next)
