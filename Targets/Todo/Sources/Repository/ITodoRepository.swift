//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation

protocol ITodoRepository: Sendable {
    func getAll() async -> [UITodo.Todo]
    func getBy(id: Int) async throws -> UITodo.Todo?
    func insert(todo: UITodo.Todo) async throws
    func delete(todo: UITodo.Todo) async throws
    func update(
        id: Int,
        title: String,
        notes: String,
        priority: UITodo.Priority,
        isCompleted: Bool
    ) async throws
}
