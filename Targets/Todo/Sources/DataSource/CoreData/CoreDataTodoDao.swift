//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import SuperLog
import CoreData

final class CoreDataTodoDao: ITodoDao {
    typealias TodoEntity = CDTodo
    typealias PriorityEntity = CDTodoPriority
    
    private let database: ICoreDataDatabase
    private let context: NSManagedObjectContext
    
    init(container: NSPersistentContainer = CoreDataDataSource.shared.persistentContainer) {
        self.context = container.newBackgroundContext()
        self.database = CoreDataDatabase(context: container.newBackgroundContext())
    }

    func getAll() async -> [CDTodo] {
        let request = CDTodo.fetchRequest()

        let data = try? await database.fetch(request)

        SuperLog.d("data: \(String(describing: data))")

        return data ?? []
    }

    func getBy(id: Int) async -> CDTodo? {
        let request = CDTodo.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        request.fetchLimit = 1

        let data = try? await database.fetch(request)

        return data?.first
    }

    func insert(title: String, notes: String, priority: CDTodoPriority) async throws {
        let todo = CDTodo(context: context)
        todo.id = Int64(UUID().hashValue)
        todo.title = title
        todo.notes = notes
        todo.priority = priority
        
        try await database.save()
    }

    func delete(entity todo: CDTodo) async throws {
        await database.delete(todo)
        try await database.save()
    }

    func update(entity todo: CDTodo, title: String, notes: String, priority: CDTodoPriority) async throws {
        todo.title = title
        todo.notes = notes
        todo.priority = priority

        try await database.save()
    }
}
