//: [Previous](@previous)

import Foundation

/*:
 # Task Groups

 You can group multiple tasks together using TaskGroup or ThrowingTaskGroup, making it easy to manage concurrent tasks and aggregate their results.
 */

func downloadPhoto(named: String) async -> Data {
    print("Downloading photo '\(named)'...")
    let waitTime = Int.random(in: 1 ... 5)
    try? await Task.sleep(for: .seconds(waitTime))
    print("Download done: '\(named)'")
    return Data()
}

func listPhotos(inGallery gallery: String) async -> [String] {
    try? await Task.sleep(for: .seconds(2))
    return ["photo1", "photo2", "photo3", "photo4", "photo5", "photo6"]
}

let downloadTask = Task {
    let photos = await withTaskGroup(of: Data.self) { taskGroup in
        let photoNames = await listPhotos(inGallery: "Summer Vacation")
        for name in photoNames {
            // Adding a task to a `TaskGroup` using `taskGroup.addTask` starts the task immediately.
            taskGroup.addTask {
                await downloadPhoto(named: name)
            }
        }

        var results: [Data] = []
        for await photo in taskGroup {
            results.append(photo)
        }

        return results
    }
}

downloadTask.cancel()

/*:
 ## Handle Cancellation
 */

let downloadTaskWithCancellation = Task {
    let photos = await withTaskGroup(of: Data?.self) { group in
        let photoNames = await listPhotos(inGallery: "Summer Vacation")
        for name in photoNames {
            let added = group.addTaskUnlessCancelled {
                guard !Task.isCancelled else { return nil }
                return await downloadPhoto(named: name)
            }
            guard added else { break }
        }

        var results: [Data] = []
        for await photo in group {
            if let photo { results.append(photo) }
        }
        return results
    }
}

downloadTaskWithCancellation.cancel()

/*:
 **Note**: If the code to download a photo could throw an error, you would call `withThrowingTaskGroup(of:returning:body:)` instead.
 */

//: [Next](@next)
