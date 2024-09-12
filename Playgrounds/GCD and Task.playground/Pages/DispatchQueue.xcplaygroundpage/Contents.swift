//: [Previous](@previous)

import Foundation

/*:
 # Dispatch

 Dispatch, also known as Grand Central Dispatch (GCD), contains language features, runtime libraries, and system enhancements that provide systemic, comprehensive improvements to the support for concurrent code execution on multicore hardware in macOS, iOS, watchOS, and tvOS.
 GCD, operating at the system level, can better accommodate the needs of all running applications, matching them to the available system resources in a balanced fashion.

 Source: https://developer.apple.com/documentation/dispatch

 # `DispatchQueue`

 An object that manages the execution of tasks serially or concurrently on your app's main thread or on a background thread.

 - Dispatch queues are FIFO queues
 - Dispatch queues execute tasks either serially (sync) or concurrently (async)
 - Except for the dispatch queue representing your app's main thread, the system makes no guarantees about which thread it uses to execute a task.
 - Attempting to synchronously execute a work item on the main queue results in deadlock.

 Source: https://developer.apple.com/documentation/dispatch/dispatchqueue

 Dispatch queues are responsible for executing tasks either serially or concurrently. There are two main types:

 - Serial Queue: Tasks are executed one at a time, in the order they are added.
 - Concurrent Queue: Multiple tasks are executed at the same time, depending on system resources.

 You can create custom queues or use predefined ones:

 - Main Queue: Runs tasks on the main thread, typically used for UI updates.
 - Global Queue: Shared background queues for concurrent tasks.

 ## Synchronous vs Asynchronous

 - Synchronous (sync): Blocks the current thread until the task completes.
 - Asynchronous (async): Returns immediately, allowing the current thread to continue while the task runs in the background.
 */

for index in 1..<10 {
    DispatchQueue.main.async {
        sleep(1000)
        print("Main: Executes Asynchronously (\(index))")
    }

    DispatchQueue.global().async {
        // Attempting to synchronously execute a work item on the main queue results in deadlock. That's why we calling it from another thread.
        DispatchQueue.main.sync {
            sleep(1000)
            print("Main: Executes Synchronously (\(index))")
        }
    }
}

for index in 1..<10 {
    DispatchQueue.global().sync {
        sleep(1000)
        print("Global: Executes Synchronously (\(index))")
    }
}

for index in 1..<10 {
    DispatchQueue.global().async {
        sleep(1000)
        print("Global: Executes Asynchronously (\(index))")
    }
}

/*:
 # QoS (Quality of Service)

 QoS defines the priority of tasks. Options include:

 - `.userInteractive`: Highest priority, for tasks affecting the UI (e.g., animations).
 - `.userInitiated`: For tasks requested by the user, requiring immediate results.
 - `.utility`: Long-running tasks that aren’t time-sensitive (e.g., downloading files).
 - `.background`: Lowest priority, for tasks that the user isn’t aware of (e.g., data syncing).
 */

for index in 1..<10 {
    DispatchQueue.global(qos: .background).async {
        sleep(1000)
        print("Global (QoS: .background): Executes Asynchronously (\(index))")
    }
}

//: [Next](@next)
