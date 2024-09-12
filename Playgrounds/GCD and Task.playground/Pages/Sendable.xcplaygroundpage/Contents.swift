//: [Previous](@previous)

import Foundation

/*:
 # `Sendable`

 `Sendable` is a protocol that ensures types can be safely passed across concurrency domains (e.g., between threads). For a type to conform to Sendable, all its stored properties must be safe to transfer between tasks without causing data races or other concurrency issues.
 */

//: ## Key Concepts

/*:
 ### Value Types and Sendable
 
 Swift’s value types (like Int, String, Array, etc.) are inherently Sendable because they’re copied when passed across threads, which makes them safe.
 */

let myInt: Int = 42 // Int is implicitly Sendable

/*:
 ### Custom Sendable Types
 
 You can make your own types conform to Sendable to ensure they can be safely passed between tasks.
 */

struct MyData: Sendable {
    let value: Int
}

/*:
 ### Classes and Sendable
 
 Classes are reference types, and reference types typically aren’t Sendable by default. You can make a class conform to Sendable if it’s safe to share across threads (e.g., immutable or thread-safe).
 */

final class MyClass: Sendable {
    let value: Int
    init(value: Int) {
        self.value = value
    }
}

/*:
 ### Actor Conformance to Sendable
 
 By default, actors do not conform to Sendable because their mutable state should be accessed through structured concurrency (like await). However, immutable actors (or actors with only let properties) can be marked as Sendable.
 */

actor MyActor: Sendable {
    let value: Int
}

//: [Next](@next)
