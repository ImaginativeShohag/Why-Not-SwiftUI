//: [Previous](@previous)

import Foundation

/*:
 # `actor`

 An `actor` is a reference type, like a `class`, that ensures **safe access** to mutable state across multiple tasks. Actors solve the problem of data races in concurrent code by providing a safe way to encapsulate mutable state, allowing only one task to access the actor’s data at a time.
 */

//: ## Key Concepts

/*:
 ### Isolation

 Only one task can access an actor’s mutable state at a time. This ensures that data races are prevented, and you don’t have to manually manage synchronization (e.g., locking).
 */

actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func getValue() -> Int {
        return value
    }
}

/*:
 ### Task-Safe Access

 Tasks must await to access actor methods and properties, ensuring thread-safe behavior.
 */

let counter = Counter()

Task {
    await counter.increment()
    let currentValue = await counter.getValue()
    print("Counter value: \(currentValue)")
}

/*:
 ### Reentrancy

 By default, actors are reentrant, meaning that an actor can suspend while awaiting and allow other tasks to access its methods. This prevents deadlocks but can introduce complexity in terms of state consistency.
 */

/*:
 ## Global Actors

 A type that represents a globally-unique actor that can be used to isolate various declarations anywhere in the program.
 Global Actors are singletons, only one instance exists. We can define a global actor as follows:
 */

@globalActor
actor DataActor {
    static let shared = DataActor()
}

/*:
 The `shared` property is a requirement of the `GlobalActor` protocol and ensures having a globally unique actor instance. Once defined, you can use the global actor throughout your project, just like you would with other actors:
 */

@DataActor
final class UserRepository {
    // ..
}

/*:
 Anywhere you use the global actor attribute, you’ll ensure synchronization through the shared actor instance to ensure mutually exclusive access to declarations.
 */

//: ### `@MainActor`

/*:
 The underlying @MainActor implementation is similar to our custom-defined @SwiftLeeActor:

 ```swift
 @globalActor
 final actor MainActor: GlobalActor {
     static let shared: MainActor
 }
 ```

 It’s available by default and defined inside the concurrency framework. In other words, you can start using this global actor immediately and mark your code to be executed on the main thread by synchronizing via this global actor.

 You can use a global actor with properties, methods, closures, and instances.
 */

@MainActor
final class HomeViewModel {
    // ...
}

@MainActor var names = [String]()

@MainActor func updateList() {
    // ...
}

//: And you can even mark closures to perform on the main thread:

func updateData(completion: @MainActor @escaping () -> ()) {
    Task {
        await someHeavyBackgroundOperation()
        await completion()
    }
}

/*:
 ### Using the main actor directly

 The MainActor in Swift comes with an extension to use the actor directly:

 ```swift
 extension MainActor {

     /// Execute the given body closure on the main actor.
     public static func run<T>(resultType: T.Type = T.self, body: @MainActor @Sendable () throws -> T) async rethrows -> T
 }
 ```

 This allows us to use the MainActor directly from within methods, even if we didn’t define any of its body using the global actor attribute:
 */

Task {
    await someHeavyBackgroundOperation()
    await MainActor.run {
        // Perform UI updates
    }
}

/*:
 ### Nonisolated Methods

 You can declare some methods as `nonisolated` if they don’t modify state and can be safely accessed from any thread without waiting.
 */

actor Logger {
    let name = "Logger"

    nonisolated func logMessage(_ message: String) {
        print("\(name): \(message)")
    }
}

let logger = Logger()
logger.logMessage("Lorem ipsum") // Called without `await`

//: [Next](@next)
