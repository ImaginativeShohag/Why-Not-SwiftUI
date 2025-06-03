//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import CoreData
import SuperLog

final actor CoreDataDataSource {
    static let shared = CoreDataDataSource()

    let persistentContainer: NSPersistentContainer

    private init() {
        let modelName = "TodoDB"

        persistentContainer = NSPersistentContainer.createContainer(modelName: modelName, bundle: .module)
        persistentContainer.loadPersistentStores(completionHandler: { _, error in
            guard let error = error as NSError? else { return }
            fatalError("###\(#function): Failed to load persistent stores:\(error)")
        })

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

        Task {
            await generateSampleDataIfNeeded(context: persistentContainer.newBackgroundContext())
        }
    }

    /// `generateSampleDataIfNeeded(context: container.newBackgroundContext())`
    func generateSampleDataIfNeeded(context: NSManagedObjectContext) {
        context.perform {
            guard let number = try? context.count(for: CDTodo.fetchRequest()), number == 0 else { return }

            let numbers = 0...9999
            for index in 1...50 {
                _ = CDTodo.create(
                    context: context,
                    id: UUID().hashValue,
                    title: "Lorem \(index)",
                    notes: "Ipsum - " + String(format: "%04d", numbers.randomElement()!),
                    priority: .low,
                    isCompleted: index % 2 == 0
                )
            }

            do {
                try context.save()
            } catch {
                print("Failed to save test data: \(error)")
            }
        }
    }
}
