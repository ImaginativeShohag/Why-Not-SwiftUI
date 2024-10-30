//: [Previous](@previous)

import Foundation

/*:
 # `DispatchWorkItem`

 A `DispatchWorkItem` allows you to encapsulate a block of code for execution and lets you cancel it if necessary.
 */

let workItem1 = DispatchWorkItem {
    // Task code
    print("Some work 1.")
}

DispatchQueue.global().async(execute: workItem1)

/*:
 ## Cancel a `DispatchWorkItem`

 - Cancellation causes future attempts to execute the work item to return immediately.
 - Cancellation does not affect the execution of a work item that has already begun.
 */

let workItem2 = DispatchWorkItem {
    sleep(3)

    // Task code
    print("Some work 2.")
}

DispatchQueue.global().async(execute: workItem2)
sleep(1)
workItem2.cancel() // Cancel task

/*: ⚠️ Here you can see the "Some work 2." is showing in the console! Because the cancelation is not handled inside the task. We have to manually stop the task where necessary. See the next example to know how to handle the cancellation.
 */

//: ## Stop the task after cancel called

var workItem3: DispatchWorkItem?
workItem3 = DispatchWorkItem {
    sleep(3)

    // Stop the work
    if workItem3?.isCancelled == true {
        print("Stopped work 3.")
        return
    }

    // Task code
    print("Some work 3.")
}

DispatchQueue.global().async(execute: workItem3!)
sleep(1)
workItem3?.cancel() // Cancel task

// Ignore. Necessary to run the playground.
sleep(4)

//: [Next](@next)


// inherit canncel..
