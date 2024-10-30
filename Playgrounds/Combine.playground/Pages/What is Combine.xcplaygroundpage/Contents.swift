//: [Previous](@previous)

/*:
 This playground book is inspired from [AvdLee/CombineSwiftPlayground](https://github.com/AvdLee/CombineSwiftPlayground).
 */

/*:
 # What is Combine?

 - A Swift implementation of observer design pattern.
 - A declarative Swift API for processing values over time.
 - Customize handling of asynchronous events by combining event-processing operators.
 - The `Publisher` protocol declares a type that can deliver a sequence of values over time.
 - `Publisher`s have operators to act on the values received from upstream publishers and republish them.
 - At the end of a chain of publishers, a `Subscriber` acts on elements as it receives them.
 - `Publisher`s only emit values when explicitly requested to do so by subscribers. This puts your subscriber code in control of how fast it receives events from the publishers it’s connected to.
 - Several Foundation types expose their functionality through publishers, including `Timer`, `NotificationCenter`, and `URLSession`.
 - Combine also provides a built-in publisher for any property that’s compliant with `Key-Value` Observing.
 */

import Combine

/*:
 # Further reading

 - [Combine](https://developer.apple.com/documentation/combine)
 */

//: [Next](@next)
