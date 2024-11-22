//: [Previous](@previous)

import Foundation
import SwiftUI
import UIKit

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

// Some task

Task { // DispatchQueue.global().async {}
    print("Task 1: \(Thread.current)")

    // Asynchronous work
    await someAsyncFunction()
}

// Some task

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
 # Async/Await Integration

 Tasks are deeply integrated with the async/await system in Swift. Within a task, you can await the result of asynchronous functions without blocking the current thread.
 */

Task {
    let result = await fetchData()
    print(result)
}

//: ## Return data from `Task`

let handle = Task {
    await fetchData()
}

let result = await handle.value

/*:
 # Asynchronous Sequences

 We can wait for one element of the collection at a time using an asynchronous sequence.
 We can use your own types in a for-await-in loop by adding conformance to the `AsyncSequence` protocol.
 */

let stream = Counter(limit: 10)

Task {
    print("Print stream values:")

    for await item in stream {
        print(item)
    }

    print("")
}

/*:
 # Calling Asynchronous Functions in Parallel
 */

func downloadPhoto(named: String) async -> Data {
    print("Downloading photo '\(named)'...")
    try? await Task.sleep(for: .seconds(1))
    return Data()
}

//: Calling an asynchronous function with await runs only one piece of code at a time. While the asynchronous code is running, the caller waits for that code to finish before moving on to run the next line of code. For example, to fetch the first three photos from a gallery, you could await three calls to the downloadPhoto(named:) function as follows:

Task {
    print("Download example 1: Init photo download")

    let firstPhoto = await downloadPhoto(named: "photo1")
    let secondPhoto = await downloadPhoto(named: "photo2")
    let thirdPhoto = await downloadPhoto(named: "photo3")

    print("Download example 1: processing...")

    let photos = [firstPhoto, secondPhoto, thirdPhoto]

    print("Download example 1: Show photos")
}

/*:
 This approach has an important drawback: Although the download is asynchronous and lets other work happen while it progresses, only one call to `downloadPhoto(named:)` runs at a time. Each photo downloads completely before the next one starts downloading. However, there’s no need for these operations to wait — each photo can download independently, or even at the same time.

 To call an asynchronous function and let it run in parallel with code around it, write `async` in front of `let` when you define a constant, and then write `await` each time you use the constant.
 */

Task {
    print("Download example 2: Init photo download")

    async let firstPhoto = downloadPhoto(named: "photo4")
    async let secondPhoto = downloadPhoto(named: "photo5")
    async let thirdPhoto = downloadPhoto(named: "photo6")

    print("Download example 2: processing...")

    let photos = await [firstPhoto, secondPhoto, thirdPhoto]

    print("Download example 2: Show photos")
}

/*:
 # Task Sleep

 Tasks can pause for a specific duration using `Task.sleep`.
 */

Task {
    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second
    print("2 second later")
}

/*:
 # Exception
 */

/*:
 The version of `listPhotos(inGallery:)` in the code above is both asynchronous and throwing, because the call to `Task.sleep(until:tolerance:clock:)` can throw an error. When you call this version of `listPhotos(inGallery:)`, you write both `try` and `await`:
 */

func listPhotos(inGallery name: String) async throws -> [String] {
    try await Task.sleep(for: .seconds(2))
    return ["IMG001", "IMG99", "IMG0404"]
}

let photos = try? await listPhotos(inGallery: "A Rainy Weekend")

/*:
 ## `Result` (⚠️ Not related to `Task`)

 You can wrap throwing code in a `do-catch` block to handle errors, or use `Result` to store the error for code elsewhere to handle it. These approaches let you call throwing functions from non-throwing code. For example:
 */

func listDownloadedPhotos(inGallery: String) throws -> [String] {
    // Some work that can throw error

    return ["Image1", "Image2", "Image3"]
}

func availableRainyWeekendPhotos() -> Result<[String], Error> {
    return Result {
        try listDownloadedPhotos(inGallery: "A Rainy Weekend")
    }
}

/*:
 # `yield()`

 A task can voluntarily suspend itself in the middle of a long-running operation that doesn’t contain any suspension points, to let other tasks run for a while before execution returns to this task.
 */

func generateSlideshow(forGallery gallery: String) async {
    let photos = try! await listPhotos(inGallery: gallery)
    for photo in photos {
        // ... render a few seconds of video for this photo ...
        await Task.yield()
    }
}

/*:
 # Alternative of `Thread.current`

 - `assumeIsolated`: Assume that the current task is executing on this actor’s serial executor, or stop program execution otherwise.
 - `preconditionIsolated`: Stops program execution if the current task is not executing on this actor’s serial executor.
 */

func mustCallFromMainActor() {
    MainActor.assumeIsolated {
        print("Current thread is MainActor isolated")
    }

    MainActor.preconditionIsolated()

    print("Code run in MainActor!")
}

mustCallFromMainActor()

//: [Next](@next)
