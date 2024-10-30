//: [Previous](@previous)

import SwiftUI

/*:
 # Task Cancellation

 Tasks support cancellation, allowing you to signal that a task should stop its execution early. You can check for cancellation using Task.isCancelled.
 */

//: Cancelling a Task:

let task1 = Task {
    await someAsyncFunction()
}

task1.cancel() // Cancel the task

if task1.isCancelled {
    print("Task 1 cancelled!")
}

//: Checking for Cancellation:

Task {
    if Task.isCancelled {
        return
    }
    await performTask()
}

/*:
 For work that needs immediate notification of cancellation, use the `Task.withTaskCancellationHandler(operation:onCancel:isolation:)` method.
 */

let task2 = Task {
    await withTaskCancellationHandler {
        try? await Task.sleep(for: .seconds(1))
        print("Working...")
        
        return 0
    } onCancel: {
        print("Task 2 cancelled!")
    }
}

// ... some time later...

task2.cancel() // Prints "Task 2 cancelled!"

//: [Next](@next)
