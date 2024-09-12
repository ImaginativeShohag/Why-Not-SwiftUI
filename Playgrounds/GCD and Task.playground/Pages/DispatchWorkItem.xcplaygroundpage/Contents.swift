//: [Previous](@previous)

import Foundation

/*:
 # `DispatchWorkItem`
 
 A `DispatchWorkItem` allows you to encapsulate a block of code for execution and lets you cancel it if necessary.
 */

let workItem = DispatchWorkItem {
    // Task code
}

DispatchQueue.global().async(execute: workItem)
workItem.cancel() // Cancel task

//: [Next](@next)
