//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

protocol ITodoDao: Sendable {
    associatedtype TodoEntity
    associatedtype PriorityEntity

    func getAll() async throws -> [TodoEntity]
    func getBy(id: Int) async throws -> TodoEntity?
    func insert(title: String, notes: String, priority: PriorityEntity, createdAt: Date, isCompleted: Bool) async throws
    func delete(entity: TodoEntity) async throws
    func update(entity: TodoEntity, title: String, notes: String, priority: PriorityEntity, isCompleted: Bool) async throws
}
