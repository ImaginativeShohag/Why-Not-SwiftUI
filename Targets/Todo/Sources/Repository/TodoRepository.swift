//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import SwiftData

class TodoRepository {
    private var database: (any IDatabase)?
    
    init() {
        SuperLog.d("Thread: \(Thread.current)")
        
        Task {
            self.database = await TodoDataSource.shared.database
        }
    }

    func getAll() async -> [Todo] {
        guard let database else { return [] }
        
        let descriptor = FetchDescriptor<Todo>()
        
        return await (try? database.fetch(descriptor)) ?? []
    }
    
    func getBy(id: Int) async -> Todo? {
        guard let database else { return nil }
        
        let predicate = #Predicate<Todo> {
            $0.id == id
        }
        
        let descriptor = FetchDescriptor<Todo>(predicate: predicate)
        let model = await (try? database.fetch(descriptor)) ?? []
        
        return model.first
    }
    
    func insert(todo: Todo) async throws {
        guard let database else { return }
        
        await database.insert(todo)
        
        try await database.save()
    }
    
    func delete(todo: Todo) async throws {
        guard let database else { return }
        
        await database.delete(todo)
        
        try await database.save()
    }
    
    func update(todo: Todo, title: String, notes: String, priority: TodoPriority) async throws {
        guard let database else { return }
        
        todo.title = title
        todo.notes = notes
        todo.priority = priority
        
        try await database.save()
    }
}
