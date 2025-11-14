//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import SuperLog
import SwiftData

final class TodoRepository: ITodoRepository {
    private let coreDataTodoDao: CoreDataTodoDao
    private let swiftDataTodoDao: SwiftDataTodoDao
    private let source: DataSourceType
    
    init(
        coreDataTodoDao: CoreDataTodoDao = CoreDataTodoDao(),
        swiftDataTodoDao: SwiftDataTodoDao = SwiftDataTodoDao(),
        source: DataSourceType = DataSourceController.shared.source
    ) {
        self.coreDataTodoDao = coreDataTodoDao
        self.swiftDataTodoDao = swiftDataTodoDao
        self.source = source
    }

    func getAll() async -> [UITodo.Todo] {
        switch source {
            case .coreData:
                let models = await coreDataTodoDao.getAll()
            
                var todos: [UITodo.Todo] = []
                for model in models {
                    let todo = await model.toUIModel()
                    todos.append(todo)
                }

                return todos
            
            case .swiftData:
                let models = await swiftDataTodoDao.getAll()
        
                var todos: [UITodo.Todo] = []
                for model in models {
                    let todo = await model.toUIModel()
                    todos.append(todo)
                }

                return todos
        }
    }
    
    func getBy(id: Int) async throws -> UITodo.Todo? {
        switch source {
            case .coreData:
                let todo = try await coreDataTodoDao.getBy(id: id)

                return await todo?.toUIModel()
            
            case .swiftData:
                let todo = try await swiftDataTodoDao.getBy(id: id)

                return await todo?.toUIModel()
        }
    }
    
    func insert(todo: UITodo.Todo) async throws {
        switch source {
            case .coreData:
                try await coreDataTodoDao.insert(
                    title: todo.title,
                    notes: todo.notes,
                    priority: CDPriority.fromUIModel(todo.priority)
                )
            
            case .swiftData:
                try await swiftDataTodoDao.insert(
                    title: todo.title,
                    notes: todo.notes,
                    priority: SDPriority.fromUIModel(todo.priority)
                )
        }
    }
    
    func delete(todo: UITodo.Todo) async throws {
        switch source {
            case .coreData:
                let dbTodo = try await coreDataTodoDao.getBy(id: todo.id)
        
                guard let dbTodo else {
                    SuperLog.e("Model not found!")
                    return
                }
            
                try await coreDataTodoDao.delete(entity: dbTodo)
            
            case .swiftData:
                let dbTodo = try await swiftDataTodoDao.getBy(id: todo.id)
    
                guard let dbTodo else {
                    SuperLog.e("Model not found!")
                    return
                }
            
                try await swiftDataTodoDao.delete(entity: dbTodo)
        }
    }
    
    func update(todo: UITodo.Todo, title: String, notes: String, priority: UITodo.Priority) async throws {
        switch source {
            case .coreData:
                let dbTodo = try await coreDataTodoDao.getBy(id: todo.id)
            
                guard let dbTodo else {
                    SuperLog.e("Model not found!")
                    return
                }
            
                try await coreDataTodoDao.update(
                    entity: dbTodo,
                    title: title,
                    notes: notes,
                    priority: CDPriority.fromUIModel(priority)
                )
            
            case .swiftData:
                let dbTodo = try await swiftDataTodoDao.getBy(id: todo.id)
        
                guard let dbTodo else {
                    SuperLog.e("Model not found!")
                    return
                }
        
                try await swiftDataTodoDao.update(
                    entity: dbTodo,
                    title: title,
                    notes: notes,
                    priority: SDPriority.fromUIModel(priority)
                )
        }
    }
}
