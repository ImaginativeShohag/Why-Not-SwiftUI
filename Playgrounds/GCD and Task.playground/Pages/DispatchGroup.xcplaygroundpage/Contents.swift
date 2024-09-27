//: [Previous](@previous)

import Foundation

/*:
 # DispatchGroup

 A group of tasks that you monitor as a single unit.

 Groups allow you to aggregate a set of tasks and synchronize behaviors on the group. You attach multiple work items to a group and schedule them for asynchronous execution on the same queue or different queues. When all work items finish executing, the group executes its completion handler. You can also wait synchronously for all tasks in the group to finish executing.
 */

/*:
 # Example for `.notify()`
 */

let dispatchGroup1 = DispatchGroup()

// First task
dispatchGroup1.enter()
DispatchQueue.global().async {
    print("Task 1 started")
    sleep(2) // Simulate time-consuming task
    print("Task 1 finished")
    dispatchGroup1.leave()
}

// Second task
dispatchGroup1.enter()
DispatchQueue.global().async {
    print("Task 2 started")
    sleep(1) // Simulate time-consuming task
    print("Task 2 finished")
    dispatchGroup1.leave()
}

// Third task
dispatchGroup1.enter()
DispatchQueue.global().async {
    print("Task 3 started")
    sleep(3) // Simulate time-consuming task
    print("Task 3 finished")
    dispatchGroup1.leave()
}

// Notify when all tasks are done
dispatchGroup1.notify(queue: .global()) {
    print("All tasks are complete! (dispatch group 1)")
}

/*:
 # Example for `.wait()`
 */

let dispatchGroup2 = DispatchGroup()

for i in (4 ... 8).reversed() {
    dispatchGroup2.enter()
    DispatchQueue.global().async {
        print("Task \(i) started")
        sleep(UInt32(i)) // Simulate varying task durations
        print("Task \(i) finished")
        dispatchGroup2.leave()
    }
}

// Wait until all tasks finish
dispatchGroup2.wait()

print("All tasks are complete! (dispatch group 2)")

//: [Next](@next)
