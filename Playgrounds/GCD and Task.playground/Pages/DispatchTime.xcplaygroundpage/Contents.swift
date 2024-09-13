//: [Previous](@previous)

import Foundation

/*:
 # `DispatchTime`
 
 DispatchTime in Swift is used to work with time-related operations in concurrency, specifically when scheduling tasks in the future or adding delays in Grand Central Dispatch (GCD). It allows you to define specific points in time or intervals to perform delayed or scheduled work. Here are some common use cases:
 */

/*:
 ## 1. Delaying Execution of a Task

 DispatchTime can be used to schedule a task to run after a specified delay. This is useful for tasks like retrying operations, delaying animations, or throttling requests.

 Example: Delaying a task by 2 seconds
 */

let delay = DispatchTime.now() + 2.0 // 2 seconds delay
DispatchQueue.main.asyncAfter(deadline: delay) {
    print("Task executed after a 2-second delay")
}

/*:
 ## 2. Scheduling Periodic Tasks

 You can use DispatchTime in combination with timers to run periodic tasks. For example, it’s useful when you need to perform background tasks at regular intervals.

 Example: Running a task every 5 seconds
 */

func schedulePeriodicTask() {
    let interval: DispatchTimeInterval = .seconds(3)

    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + interval) {
        print("Task executed (every 3 seconds)")
        schedulePeriodicTask() // Call the function again to schedule the next execution
    }
}

schedulePeriodicTask()

/*:
 ## 3. Measuring Execution Time

 DispatchTime is also useful for measuring how long a particular block of code takes to execute.

 Example: Measuring code execution time
 */

let startTime = DispatchTime.now()
// Code to be measured
sleep(2) // Simulate a time-consuming task
let endTime = DispatchTime.now()

let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
let elapsedTimeInSeconds = Double(elapsedTime) / 1_000_000_000
print("Execution took \(elapsedTimeInSeconds) seconds")

/*:
 ## 4. Timeouts for Tasks

 You can use DispatchTime to enforce timeouts when waiting for certain tasks to complete (e.g., network requests or file I/O operations). If the task doesn’t complete within the specified time, you can take action.

 Example: Using DispatchTime for timeout handling
 */

let deadline = DispatchTime.now() + .seconds(10)

DispatchQueue.global().async {
    // Simulate a long-running task
    sleep(8) // Takes 8 seconds
    print("Task finished before timeout")
}

DispatchQueue.global().asyncAfter(deadline: deadline) {
    print("Timeout reached, taking action!")
}

/*:
 ## 5. Creating Dispatch Semaphores with a Timeout

 You can use DispatchTime with semaphores to wait for resources or signals within a certain time frame, providing an option to act when the wait time expires.

 Example: Using DispatchTime with a semaphore timeout
 */

let semaphore = DispatchSemaphore(value: 0)
let timeout = DispatchTime.now() + .seconds(5)

DispatchQueue.global().async {
    sleep(3) // Simulate some work
    print("Work completed, signaling semaphore")
    semaphore.signal() // Signal semaphore after work is done
}

if semaphore.wait(timeout: timeout) == .timedOut {
    print("Task timed out")
} else {
    print("Task completed before timeout")
}

// Ignore. Necessary to run the playground.
sleep(20)

//: [Next](@next)
