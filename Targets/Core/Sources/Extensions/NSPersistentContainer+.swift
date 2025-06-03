//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CoreData

public extension NSPersistentContainer {
    /// Creates and returns a persistent container for the given model name and bundle.
    ///
    /// This method loads the managed object model from the specified bundle and initializes
    /// a `NSPersistentContainer` with it. It does not load the persistent store or configure
    /// store descriptions.
    ///
    /// - Note: If the model is in the main app target, simply use: `NSPersistentContainer(name: "model-name")`
    ///
    /// - Parameters:
    ///   - modelName: The name of the Core Data model (should match the `.xcdatamodeld` filename).
    ///   - bundle: The bundle containing the model resource.
    /// - Returns: An instance of `NSPersistentContainer` initialized with the specified model.
    static func createContainer(modelName: String, bundle: Bundle = Bundle.main) -> NSPersistentContainer {
        // We do not need any extra work if it is main bundle (The data file in the main target).
        if bundle == Bundle.main {
            return NSPersistentContainer(name: modelName)
        }
        
        // Locate the model in the framework's bundle
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd") else {
            fatalError("Failed to find model file in framework bundle.")
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load NSManagedObjectModel from: \(modelURL)")
        }

        // Initialize container with the loaded model
        return NSPersistentContainer(name: modelName, managedObjectModel: model)
    }

    /// Creates and returns an in-memory persistent container for the given model name and bundle.
    ///
    /// This method loads the managed object model from the specified bundle and configures
    /// an `NSPersistentContainer` to use an in-memory store, making it ideal for previews or testing.
    /// The persistent store is not written to disk.
    ///
    /// - Note: If the model is in the main app target, simply use: `NSPersistentContainer(name: "model-name")`
    ///
    /// - Parameters:
    ///   - modelName: The name of the Core Data model (should match the `.xcdatamodeld` filename).
    ///   - bundle: The bundle containing the model resource.
    /// - Returns: An instance of `NSPersistentContainer` configured with an in-memory store.
    static func createInMemoryContainer(modelName: String, bundle: Bundle = Bundle.main) -> NSPersistentContainer {
        // Initialize container with the loaded model
        let container = NSPersistentContainer.createContainer(modelName: modelName, bundle: bundle)

        // Configure in-memory store

        // Setting the url to /dev/null tells Core Data explicitly not to use a file path
        // container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")

        // Alternative:
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        return container
    }
}
