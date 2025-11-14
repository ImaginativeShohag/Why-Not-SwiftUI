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
    private let container: NSPersistentContainer = CoreDataDataSource.shared.persistentContainer

    init(container: NSPersistentContainer = CoreDataDataSource.shared.persistentContainer) {
        let newContext = container.viewContext
        self.context = newContext
        self.database = CoreDataDatabase(context: newContext)
    }

    func getAll() async -> [CDTodo] {
        let request = CDTodo.fetchRequest()

        let data = try? await database.fetch(request)

        SuperLog.d("data: \(String(describing: data))")

        return data ?? []
    }

    func getBy(id: Int) async throws -> CDTodo? {
        SuperLog.d("id: \(id)")

        let request = CDTodo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)
        request.fetchLimit = 1

        let data = try await database.fetch(request)

        return data.first
    }

    func insert(title: String, notes: String, priority: CDPriority) async throws {
        let todo = CDTodo(context: context)
        todo.id = Int64(Date().timeIntervalSince1970 * 1000)
        todo.title = title
        todo.notes = notes
        todo.priority = priority

        try await database.save()
    }

    func delete(entity todo: CDTodo) async throws {
        await database.delete(todo)
        try await database.save()
    }

    func update(entity todo: CDTodo, title: String, notes: String, priority: CDPriority) async throws {
        todo.title = title
        todo.notes = notes
        todo.priority = priority

        try await database.save()
    }
}
