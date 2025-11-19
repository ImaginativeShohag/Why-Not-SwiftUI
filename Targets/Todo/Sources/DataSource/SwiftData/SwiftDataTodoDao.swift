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

    func getAll() async throws -> [SDTodo] {
        let descriptor = FetchDescriptor<SDTodo>()
        let todos = try await database.fetch(descriptor)

        return todos
    }
    
    func getBy(id: Int) async throws -> SDTodo? {
        let predicate = #Predicate<SDTodo> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<SDTodo>(predicate: predicate)
        let models = try await database.fetch(descriptor)
        
        return models.first
    }
    
    func insert(title: String, notes: String, priority: SDPriority, createdAt: Date, isCompleted: Bool) async throws {
        // Generate a more robust ID using a combination of timestamp and random value
        // to avoid collisions when multiple todos are created quickly
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let randomComponent = Int.random(in: 0..<1000)
        let uniqueId = timestamp * 1000 + randomComponent

        let todo = SDTodo(
            id: uniqueId,
            title: title,
            notes: notes,
            priority: priority,
            createdAt: createdAt,
            isCompleted: isCompleted
        )

        await database.insert(todo)

        try await database.save()
    }
    
    func delete(entity: SDTodo) async throws {
        await database.delete(entity)
        
        try await database.save()
    }
    
    func update(entity: SDTodo, title: String, notes: String, priority: SDPriority, isCompleted: Bool) async throws {
        // Update the entity directly without refetching
        entity.title = title
        entity.notes = notes
        entity.priority = priority
        entity.isCompleted = isCompleted

        try await database.save()
    }
}
