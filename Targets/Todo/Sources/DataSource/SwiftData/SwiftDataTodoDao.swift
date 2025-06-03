//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import SuperLog
import SwiftData

final class SwiftDataTodoDao: ITodoDao {
    typealias TodoEntity = Todo
    typealias PriorityEntity = Priority
    
    private let database: any ISwiftDataDatabase
    
    init(
        container: ModelContainer = SwiftDataDataSource.shared.container
    ) {
        self.database = SwiftDataDatabase(modelContainer: container)
    }

    func getAll() async -> [Todo] {
        let descriptor = FetchDescriptor<Todo>()
        let todos = try? await database.fetch(descriptor)

        SuperLog.d("todos: \(String(describing: todos))")

        return todos ?? []
    }
    
    func getBy(id: Int) async -> Todo? {
        let predicate = #Predicate<Todo> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<Todo>(predicate: predicate)
        let models = await (try? database.fetch(descriptor)) ?? []
        
        return models.first
    }
    
    func insert(title: String, notes: String, priority: Priority) async throws {
        let todo = Todo(
            id: UUID().hashValue,
            title: title,
            notes: notes,
            priority: priority,
            createdAt: Date(),
            isCompleted: false
        )
        
        await database.insert(todo)
        
        try await database.save()
    }
    
    func delete(entity: Todo) async throws {
        await database.delete(entity)
        
        try await database.save()
    }
    
    func update(entity: Todo, title: String, notes: String, priority: Priority) async throws {
        let id = entity.id
        let predicate = #Predicate<Todo> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<Todo>(predicate: predicate)
        guard let models = await (try? database.fetch(descriptor)), let dbModel = models.first else { return }
            
        dbModel.title = title
        dbModel.notes = notes
        dbModel.priority = priority
        
        try await database.save()
    }
}
