//: [Previous](@previous)

import Foundation

/*:
 # `DispatchSemaphore`

 An object that controls access to a resource across multiple execution contexts through use of a traditional counting semaphore.

 You increment a semaphore count by calling the signal() method, and decrement a semaphore count by calling wait() or one of its variants that specifies a timeout.
 */

let semaphore = DispatchSemaphore(value: 2) // 2 task at a time

for index in 1 ... 10 {
    DispatchQueue.global().async {
        semaphore.wait() // Wait for resource

        print("Task \(index) started")
        sleep(1) // Simulate time-consuming task
        print("Task \(index) finished")

        semaphore.signal() // Release resource
    }
}

//: [Next](@next)
