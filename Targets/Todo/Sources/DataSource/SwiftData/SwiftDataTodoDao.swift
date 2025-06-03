//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import SuperLog
import SwiftData

final class SwiftDataTodoDao: ITodoDao {
    typealias TodoEntity = SDTodo
    typealias PriorityEntity = SDPriority
    
    private let database: SwiftDataDatabase
    
    init(
        container: ModelContainer = SwiftDataDataSource.shared.container
    ) {
        self.database = SwiftDataDatabase(modelContainer: container)
    }

    func getAll() async -> [SDTodo] {
        let descriptor = FetchDescriptor<SDTodo>()
        let todos = try? await database.fetch(descriptor)

        SuperLog.d("todos: \(String(describing: todos))")

        return todos ?? []
    }
    
    func getBy(id: Int) async -> SDTodo? {
        let predicate = #Predicate<SDTodo> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<SDTodo>(predicate: predicate)
        let models = await (try? database.fetch(descriptor)) ?? []
        
        return models.first
    }
    
    func insert(title: String, notes: String, priority: SDPriority) async throws {
        let todo = SDTodo(
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
    
    func delete(entity: SDTodo) async throws {
        await database.delete(entity)
        
        try await database.save()
    }
    
    func update(entity: SDTodo, title: String, notes: String, priority: SDPriority) async throws {
        let id = entity.id
        let predicate = #Predicate<SDTodo> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<SDTodo>(predicate: predicate)
        guard let models = await (try? database.fetch(descriptor)), let dbModel = models.first else { return }
            
        dbModel.title = title
        dbModel.notes = notes
        dbModel.priority = priority
        
        try await database.save()
    }
}
