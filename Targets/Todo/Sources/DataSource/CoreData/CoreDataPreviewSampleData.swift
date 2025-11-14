//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import CoreData
import Foundation
import SuperLog

#if DEBUG

enum CoreDataPreviewSampleData {
    static let container: NSPersistentContainer = inMemoryContainer()

    private static func inMemoryContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer.createInMemoryContainer(modelName: "TodoDB", bundle: .module)

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true

        let context = container.newBackgroundContext()

        // MARK: Generate Mock Data

        for index in 1 ... 50 {
            let newTodo = CDTodo.create(
                context: context,
                id: UUID().hashValue,
                title: "Lorem \(index)",
                notes: "Ipsum - \(index)",
                priority: .low,
                isCompleted: index % 2 == 0
            )
        }

        do {
            try context.save()
        } catch {
            print("Failed to save preview data: \(error)")
        }

        return container
    }
}

#endif
