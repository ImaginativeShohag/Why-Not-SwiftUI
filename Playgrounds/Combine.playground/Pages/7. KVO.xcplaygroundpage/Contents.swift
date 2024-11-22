//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Performing Key-Value Observing with Combine
 
 You can only use key-value observing with classes that inherit from `NSObject`.
 */

//: Define a Class with a KVO-Compliant Property:

class Person: NSObject {
    /// The `name` property of a `Person`, which is observable using Key-Value Observing (KVO).
    ///
    /// - Note: This property is marked with `@objc` and `dynamic` to enable compatibility with Objective-C's KVO, allowing you to observe changes to its value.
    ///         This setup also enables using it with Combine's `publisher(for:)` method to create a reactive publisher for changes to `name`.
    @objc dynamic var name: String = ""
}

//: Set Up KVO Observation with Combine:

let person = Person()
var cancellable: AnyCancellable?

//: Using KVO publisher to observe the `name` property

cancellable = person.publisher(for: \.name)
    .sink { newValue in
        print("Name changed to \(newValue)")
    }

//: Update the Property:

person.name = "Alice"
person.name = "Bob"

/*:
 # Further reading

 - [Performing Key-Value Observing with Combine](https://developer.apple.com/documentation/combine/performing-key-value-observing-with-combine)
 - [Using Key-Value Observing in Swift](https://developer.apple.com/documentation/swift/using-key-value-observing-in-swift)
 */

//: [Next](@next)
