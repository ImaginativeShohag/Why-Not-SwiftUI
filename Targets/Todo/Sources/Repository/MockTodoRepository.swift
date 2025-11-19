//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

@MainActor
final class MockTodoRepository: ITodoRepository {
    private var todos: [UITodo.Todo] = [
        UITodo.Todo(id: 1, title: "Buy groceries", notes: "Milk, Bread, Eggs", priority: .medium),
        UITodo.Todo(id: 2, title: "Read a book", notes: "Start 'Atomic Habits'", priority: .low),
        UITodo.Todo(id: 3, title: "Workout", notes: "30 mins cardio", priority: .high)
    ]

    func getAll() async -> [UITodo.Todo] {
        return todos
    }

    func getBy(id: Int) async -> UITodo.Todo? {
        return todos.first { $0.id == id }
    }

    func insert(todo: UITodo.Todo) async throws {
        todos.append(todo)
    }

    func delete(todo: UITodo.Todo) async throws {
        todos.removeAll { $0.id == todo.id }
    }

    func update(
        id: Int,
        title: String,
        notes: String,
        priority: UITodo.Priority,
        isCompleted: Bool
    ) async throws {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }
        let updated = UITodo.Todo(
            id: id,
            title: title,
            notes: notes,
            priority: priority,
            createdAt: Date(),
            isCompleted: isCompleted
        )
        todos[index] = updated
    }
}
