//: [Previous](@previous)

import Combine
import Foundation

/*:
 # Publishers and Subscribers

 - A Publisher _publishes_ values ...
 - .. a subscriber _subscribes_ to receive publisher's values

 __Specifics__:

 - Publishers are _typed_ to the data and error types they can emit
 - A publisher can emit, zero, one or more values and terminate gracefully or with an error of the type it declared.
 */

/*:
 ## Example 1

 "publish" just one value then complete
  */
let publisher1 = Just(42)

//: You need to _subscribe_ to receive values (here using a sink with a closure)
let subscription1 = publisher1.sink { value in
    print("Received value from publisher1: \(value)")
}

//: Another variation of `sink`
publisher1.sink { completion in
    print("Received completion from publisher1: \(completion)")
} receiveValue: { value in
    print("(Variation) Received value from publisher1: \(value)")
}

/*:
 ## Example 2

 "publish" a series of values immediately
  */
let publisher2 = [1, 2, 3, 4, 5].publisher

let subscription2 = publisher2
    .sink { value in
        print("Received value from publisher2: \(value)")
    }

/*:
 ## Example 3

 Assign publisher values to a property on an object
  */
print("")

class MyClass {
    var property: Int = 0 {
        didSet {
            print("Did set property to \(property)")
        }
    }
}

let object = MyClass()
let subscription3 = publisher2.assign(to: \.property, on: object)

//: [Next](@next)
