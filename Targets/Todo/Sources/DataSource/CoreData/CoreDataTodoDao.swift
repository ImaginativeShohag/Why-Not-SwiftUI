//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import CoreData
import Foundation
import SuperLog

final class CoreDataTodoDao: ITodoDao {
    typealias TodoEntity = CDTodo
    typealias PriorityEntity = CDPriority

    private let database: CoreDataDatabase
    private let context: NSManagedObjectContext

    init(container: NSPersistentContainer = CoreDataDataSource.shared.persistentContainer) {
        let newContext = container.viewContext
        self.context = newContext
        self.database = CoreDataDatabase(context: newContext)
    }

    func getAll() async throws -> [CDTodo] {
        let request = CDTodo.fetchRequest()
        let data = try await database.fetch(request)

        return data
    }

    func getBy(id: Int) async throws -> CDTodo? {
        SuperLog.d("id: \(id)")

        let request = CDTodo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)
        request.fetchLimit = 1

        let data = try await database.fetch(request)

        return data.first
    }

    func insert(title: String, notes: String, priority: CDPriority, createdAt: Date, isCompleted: Bool) async throws {
        // Generate a more robust ID using a combination of timestamp and random value
        // to avoid collisions when multiple todos are created quickly
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let randomComponent = Int64.random(in: 0..<1000)
        let uniqueId = timestamp * 1000 + randomComponent

        let todo = CDTodo(context: context)
        todo.id = uniqueId
        todo.title = title
        todo.notes = notes
        todo.priority = priority
        todo.createdAt = createdAt
        todo.isCompleted = isCompleted

        try await database.save()
    }

    func delete(entity todo: CDTodo) async throws {
        await database.delete(todo)
        try await database.save()
    }

    func update(entity todo: CDTodo, title: String, notes: String, priority: CDPriority, isCompleted: Bool) async throws {
        todo.title = title
        todo.notes = notes
        todo.priority = priority
        todo.isCompleted = isCompleted

        try await database.save()
    }
}
