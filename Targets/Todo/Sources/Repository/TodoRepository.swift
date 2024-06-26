//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import SwiftData

@globalActor actor DataActor {
    static var shared = DataActor()
}

@DataActor
final class TodoRepository {
    private lazy var database: any IDatabase = TodoDataSource.shared.database
    
    nonisolated init() {
        SuperLog.d("Thread: \(Thread.current)")
    }

    func getAll() async -> [Todo] {
        let descriptor = FetchDescriptor<Todo>()
        
        let data = try? await database.fetch(descriptor)
        
        return data ?? []
    }
    
    func getBy(id: Int) async -> Todo? {
        let predicate = #Predicate<Todo> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<Todo>(predicate: predicate)
        let model = await (try? database.fetch(descriptor)) ?? []
        
        return model.first
    }
    
    func insert(todo: Todo) async throws {
        await database.insert(todo)
        
        try await database.save()
    }
    
    func delete(todo: Todo) async throws {
        await database.delete(todo)
        
        try await database.save()
    }
    
    func update(todo: Todo, title: String, notes: String, priority: TodoPriority) async throws {
        todo.title = title
        todo.notes = notes
        todo.priority = priority
        
        try await database.save()
    }
}
