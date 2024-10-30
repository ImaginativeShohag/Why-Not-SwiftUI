//: [Previous](@previous)

import Foundation

/*:
 # `Sendable`

 `Sendable` is a protocol that ensures types can be safely passed across concurrency domains (e.g., between threads). For a type to conform to `Sendable`, all its stored properties must be safe to transfer between tasks without causing data races or other concurrency issues.

 You can safely pass values of a sendable type from one concurrency domain to another — for example, you can pass a sendable value as the argument when calling an actor’s methods. All of the following can be marked as sendable:

 - Value types
 - Reference types with no mutable storage
 - Reference types that internally manage access to their state
 - Functions and closures (by marking them with `@Sendable`)
 */

//: ## Key Concepts

/*:
 ### Value Types and Sendable

 Swift’s value types (like Int, String, Array, etc.) are inherently Sendable because they’re copied when passed across threads, which makes them safe.
 */

let myInt: Int = 42 // Int is implicitly Sendable

/*:
 ### Sendable Structures and Enumerations

 To satisfy the requirements of the `Sendable` protocol, an enumeration or structure must have only sendable members and associated values. In some cases, structures and enumerations that satisfy the requirements implicitly conform to `Sendable`:

 - Frozen structures and enumerations
 - Structures and enumerations that aren’t public and aren’t marked `@usableFromInline`.

 Otherwise, you need to declare conformance to Sendable explicitly.

 Structures that have nonsendable stored properties and enumerations that have nonsendable associated values can be marked as `@unchecked Sendable`, disabling compile-time correctness checks, **after you manually verify that they satisfy the Sendable protocol’s semantic requirements**.
 */

struct MyStruct: Sendable {
    let value: Int
}

enum MyEnum: Sendable {
    case value(Int)
}

/*:
 ### Actor Conformance to Sendable

 All actor types implicitly conform to Sendable because actors ensure that all access to their mutable state is performed sequentially.
 */

actor MyActor: Sendable {
    var value: Int = 42
}

/*:
 ### Sendable Classes

 Classes are reference types, and reference types typically aren’t Sendable by default. You can make a class conform to Sendable if it’s safe to share across threads (e.g., immutable or thread-safe).

 To satisfy the requirements of the Sendable protocol, a class must:

 - Be marked `final`
 - Contain only stored properties that are immutable and sendable
 - Have no superclass or have `NSObject` as the superclass
 */

final class MyClass: Sendable {
    let value: Int

    init(value: Int) {
        self.value = value
    }
}

/*:
 #### Classes marked with `@MainActor`

 Classes marked with `@MainActor` are implicitly sendable, because the main actor coordinates all access to its state. These classes can have stored properties that are mutable and nonsendable.
 */

@MainActor
final class MyAnotherClass: Sendable {
    // Add `@MainActor` removes the following warning from `value` variable:
    // Stored property 'value' of 'Sendable'-conforming class 'MyAnotherClass' is mutable; this is an error in the Swift 6 language mode
    var value: Int

    init(value: Int) {
        self.value = value
    }
}

/*:
 #### `@unchecked Sendable`

 Classes that don’t meet the requirements above can be marked as `@unchecked Sendable`, disabling compile-time correctness checks, after you manually verify that they satisfy the Sendable protocol’s semantic requirements.
 */

// A simple thread-safe counter class
final class Counter: @unchecked Sendable {
    // Add `@unchecked Sendable` removes the following warning from `count` variable:
    // Stored property 'value' of 'Sendable'-conforming class 'Counter' is mutable; this is an error in the Swift 6 language mode
    private var count: Int = 0
    private let lock = NSLock()

    // Increment the count
    func increment() {
        lock.lock() // Lock to ensure thread safety
        count += 1
        lock.unlock()
    }

    // Decrement the count
    func decrement() {
        lock.lock()
        count -= 1
        lock.unlock()
    }

    // Get the current count
    func getCount() -> Int {
        lock.lock()
        let currentCount = count
        lock.unlock()
        return currentCount
    }
}

let counter = Counter()

DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    counter.increment()
}

print("Final counter value: \(counter.getCount())")

/*:
 ### Sendable Functions and Closures

 Instead of conforming to the `Sendable` protocol, you mark sendable functions and closures with the `@Sendable` attribute. Any values that the function or closure captures must be sendable. In addition, sendable closures must use only by-value captures, and the captured values must be of a sendable type.

 In a context that expects a sendable closure, a closure that satisfies the requirements implicitly conforms to Sendable — for example, in a call to `Task.detached(priority:operation:)`.

 You can explicitly mark a closure as sendable by writing `@Sendable` as part of a type annotation, or by writing `@Sendable` before the closure’s parameters — for example:
 */

let sendableClosure = { @Sendable (number: Int) -> String in
    if number > 12 {
        return "More than a dozen."
    } else {
        return "Less than a dozen"
    }
}

/*:
 ### Sendable Tuples

 To satisfy the requirements of the `Sendable` protocol, all of the elements of the tuple must be sendable. Tuples that satisfy the requirements implicitly conform to `Sendable`.
 */

/*:
 ### Sendable Metatypes

 Metatypes such as `Int.Type` implicitly conform to the `Sendable` protocol.
 */

/*:
 # Further reading

 - [Official `Sendable` Documentation](https://developer.apple.com/documentation/swift/sendable)
 - [Sendable and @Sendable closures explained with code examples](https://www.avanderlee.com/swift/sendable-protocol-closures/)
 - [Actors in Swift: how to use and prevent data races](https://www.avanderlee.com/swift/actors/)
 */

//: [Next](@next)
