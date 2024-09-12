//: [Previous](@previous)

import Foundation

//: # Structured Concurrency

/*:
 # Creating Tasks

 A Task represents a unit of asynchronous work. You can create a task to run concurrent operations without blocking the current thread.
 */

Task {
    // Asynchronous work
    await someAsyncFunction()
}

/*:
 # Detached Tasks

 Detached tasks run independently of their parent tasks. They don’t inherit the context (such as priority) of the task that created them.
 */

Task.detached {
    await performAsyncOperation()
}

/*:
 # Task Priority

 You can specify the priority of tasks (e.g., .high, .low, .background), which helps the system schedule them accordingly.
 */

Task(priority: .high) {
    await highPriorityWork()
}

/*:
 # Cancellation

 Tasks support cancellation, allowing you to signal that a task should stop its execution early. You can check for cancellation using Task.isCancelled.
 */

//: Checking for Cancellation:

Task {
    if Task.isCancelled {
        return
    }
    await performTask()
}

//: Cancelling a Task:

let task = Task {
    await someAsyncFunction()
}

task.cancel() // Cancel the task

/*:
 # Async/Await Integration

 Tasks are deeply integrated with the async/await system in Swift. Within a task, you can await the result of asynchronous functions without blocking the current thread.
 */

Task {
    let result = await fetchData()
    print(result)
}

/*:
 # Task Groups

 You can group multiple tasks together using TaskGroup or ThrowingTaskGroup, making it easy to manage concurrent tasks and aggregate their results.
 */

Task {
    await withTaskGroup(of: String.self) { group in
        group.addTask {
            await performTask1()
        }
        group.addTask {
            await performTask2()
        }
        for await result in group {
            print(result)
        }
    }
}

/*:
 # Task Sleep

 Tasks can pause for a specific duration using `Task.sleep`.
 */

Task {
    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second
    print("2 second later")
}

//: [Next](@next)
