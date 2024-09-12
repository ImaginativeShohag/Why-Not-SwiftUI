//: [Previous](@previous)

import Foundation

/*:
 # `Task` equivalent for `DispatchQueue`:

 - `DispatchQueue.main.async` -> `Task { @MainActor in ... }`
 - `DispatchQueue.main.sync` -> `await MainActor.run { ... }`
 - `DispatchQueue.global().async` -> `Task.detached { ... }` or `Task.detached(priority: .background) { ... }`
 - `DispatchQueue.global().sync` -> No valid use case found
 */

/*:

 Let's examine each combination and determine if they are valid or commonly used patterns in Swift's concurrency model.

 ### 1. **`DispatchQueue.main.async` -> `Task { @MainActor in ... }`**
 
 - **Explanation**:
     - `DispatchQueue.main.async` schedules a task to run asynchronously on the main thread using GCD.
     - `Task { @MainActor in ... }` creates a Swift concurrency task and ensures that it runs on the main actor (which corresponds to the main thread).

 - **Validity**: Yes, this is **valid**.
     - Even though both methods aim to run the code on the main thread, mixing them is valid, but might be redundant. You don’t need both GCD and Swift concurrency to ensure the code runs on the main actor. Either approach suffices on its own.

     **Preferable approach**:
     ```swift
     Task { @MainActor in
         // Run code on the main thread using Swift concurrency
     }
     ```
     Using Swift's `@MainActor` directly is simpler.

 ---

 ### 2. **`DispatchQueue.main.sync` -> `await MainActor.run { ... }`**
 
 - **Explanation**:
     - `DispatchQueue.main.sync` runs code synchronously on the main thread.
     - `await MainActor.run { ... }` runs a block of code on the main actor (main thread), but the code is wrapped in `async/await`.

 - **Validity**: This is **valid**, but potentially problematic.
     - `DispatchQueue.main.sync` blocks the current thread and waits for the task to finish. Using it together with `await` can lead to a **deadlock** if the current code is already on the main thread. This happens because `await MainActor.run { ... }` needs to suspend execution, but `sync` doesn’t allow the current thread to suspend.

     **Correct approach**: Use `async` with `MainActor.run` to avoid deadlocks:
     ```swift
     await MainActor.run {
         // Code running on the main thread
     }
     ```
     Avoid `DispatchQueue.main.sync` with asynchronous tasks on the main thread.

 ---

 ### 3. **`DispatchQueue.global().async` -> `Task.detached { ... }` or `Task.detached(priority: .background) { ... }`**
 
 - **Explanation**:
     - `DispatchQueue.global().async` schedules work asynchronously on a background thread using GCD.
     - `Task.detached { ... }` creates a Swift concurrency task that runs independently of the current context and can have a specified priority.

 - **Validity**: Yes, both combinations are **valid**.
     - `DispatchQueue.global().async` is a lower-level GCD mechanism, while `Task.detached` is part of Swift's structured concurrency. They both schedule tasks to run in the background, but Swift's concurrency system (`Task.detached`) offers more benefits like cancellation, priority control, and structured concurrency features.

     **Preferable approach**:
     ```swift
     Task.detached(priority: .background) {
         // Run task in background using Swift concurrency
     }
     ```
     Use `Task.detached` for Swift's native concurrency and avoid mixing GCD unless necessary for legacy code.

 ---

 ### Summary:
 
 - **`DispatchQueue.main.async` -> `Task { @MainActor in ... }`**: Valid but redundant. Prefer `Task { @MainActor in ... }`.
 - **`DispatchQueue.main.sync` -> `await MainActor.run { ... }`**: Valid but can cause a deadlock. Use `await MainActor.run { ... }` alone.
 - **`DispatchQueue.global().async` -> `Task.detached { ... }`**: Valid. Prefer `Task.detached` for Swift concurrency features.
 */

//: [Next](@next)
