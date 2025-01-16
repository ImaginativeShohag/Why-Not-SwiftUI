//: [Previous](@previous)

import Combine
import Foundation

/*:
 # Simple operators

 - Operators are functions defined on publisher instances...
 - ... each operator returns a new publisher ...
 - ... operators can be chained to add processing steps
 */

/*:
 ## `map`

 - works like Swift's `map`
 - ... operates on values over time
 */
let publisher1 = PassthroughSubject<Int, Never>()

let publisher2 = publisher1.map { value in
    value + 100
}

let subscription1 = publisher1
    .sink { value in
        print("Subscription1 received integer: \(value)")
    }

let subscription2 = publisher2
    .sink { value in
        print("Subscription2 received integer: \(value)")
    }

print("* Demonstrating map operator")
print("Publisher1 emits 28")
publisher1.send(28)

print("Publisher1 emits 50")
publisher1.send(50)

subscription1.cancel()
subscription2.cancel()

//: ----------------------------------------------------------------

/*:
 ## `filter`

 - works like Swift's `filter`
 - ... operates on values over time
 */

let publisher3 = publisher1.filter {
    // only let even values pass through
    ($0 % 2) == 0
}

let subscription3 = publisher3
    .sink { value in
        print("Subscription3 received integer: \(value)")
    }

print("\n* Demonstrating filter operator")
print("Publisher1 emits 14")
publisher1.send(14)

print("Publisher1 emits 15")
publisher1.send(15)

print("Publisher1 emits 16")
publisher1.send(16)

//: ----------------------------------------------------------------

/*:
 ## `reduce`
 
 The reduce operator in Swift Combine applies a closure to each element emitted by a publisher, accumulating the results and emitting only the final value when the stream completes.
 
 - Starts with an initial value.
 - Applies a provided closure to each emitted element, combining it with the accumulated result.
 - Emits the final accumulated result when the publisher completes.
 */

let numbers2 = [1, 2, 3, 4, 5].publisher

let subscription5 = numbers2
    .reduce(0) { accumulatedValue, newValue in
        accumulatedValue + newValue
    }
    .sink { result in
        print("Final accumulated value: \(result)")
    }

// Output:
// Final accumulated value: 15

//: ### Another example

let words = ["Hello", "Combine", "World"].publisher

let subscription6 = words
    .reduce("") { result, word in
        result + " " + word
    }
    .sink { finalResult in
        print(finalResult.trimmingCharacters(in: .whitespaces))
    }

// Output:
// Hello Combine World

/*:
 Use Cases:

 - Summing Values: Calculate the total from a series of numbers.
 - Aggregation: Concatenate strings or combine data into a single result.
 - Final Computation: When only the end result matters, not intermediate steps.
 */

//: ----------------------------------------------------------------

/*:
 ## `scan`
 
 The scan operator in Swift Combine applies a closure to each element emitted by a publisher, accumulating results over time and producing an ongoing sequence of values.
 
 - Similar to the `reduce` method but emits the intermediate results after each calculation.
 - Starts with an initial value and applies the provided closure cumulatively to each element emitted.
 - Each new value depends on the previous result and the next incoming element.
 */

let numbers1 = [1, 2, 3, 4, 5].publisher

let subscription4 = numbers1
    .scan(0) { accumulatedValue, newValue in
        accumulatedValue + newValue
    }
    .sink { result in
        print("Accumulated value: \(result)")
    }

// Output:
// Accumulated value: 1
// Accumulated value: 3
// Accumulated value: 6
// Accumulated value: 10
// Accumulated value: 15

/*:
 Use Cases:

 - Running Totals: Calculating cumulative sums or aggregations.
 - State Management: Building up state from a stream of data (like a counter or progress tracker).
 - Transforming Sequences: Modifying values based on previous data.
 */

//: [Next](@next)

