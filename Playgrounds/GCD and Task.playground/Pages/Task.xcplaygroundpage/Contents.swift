//: [Previous](@previous)

import Foundation

//: # Structured Concurrency Model

print("Current Thread: \(Thread.current)")

/*:
 # Async function

 We can create a async function using `async` keyword.
 */

func exampleAsyncFunction() async {
    // some task
}

/*:
 # Creating Tasks

 A Task represents a unit of asynchronous work. You can create a task to run concurrent operations without blocking the current thread.
 */

 Task {
    print("Task 1: \(Thread.current)")
     
    // Asynchronous work
    await someAsyncFunction()
 }

/*:
 # Context inheritance

 `Task` inherit the
 */

Task { @MainActor in
    print("Task 2: \(Thread.current)")

    await someAsyncFunction()

    Task {
        print("Task 3: \(Thread.current)")
        
        // Asynchronous work
        await someAsyncFunction()
    }
}

Task {
    print("Task 4: \(Thread.current)")

    await someAsyncFunction()

    Task { @MainActor in
        print("Task 5: \(Thread.current)")
        
        // Asynchronous work
        await someAsyncFunction()
    }
}

/*:
 # Detached Tasks

 Detached tasks run independently of their parent tasks. They don’t inherit the context (such as priority) of the task that created them.
 */

Task.detached {
    print("Task 6 (detached): \(Thread.current)")
    
    await performAsyncOperation()
}

Task { @MainActor in
    print("Task 7: \(Thread.current)")

    await someAsyncFunction()

    Task.detached {
        print("Task 8: \(Thread.current)")
        
        // Asynchronous work
        await someAsyncFunction()
    }
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

// Yield example

//: [Next](@next)
