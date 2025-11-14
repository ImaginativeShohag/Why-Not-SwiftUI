//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

protocol ITodoDao {
    associatedtype TodoEntity
    associatedtype PriorityEntity

    func getAll() async -> [TodoEntity]
    func getBy(id: Int) async throws -> TodoEntity?
    func insert(title: String, notes: String, priority: PriorityEntity) async throws
    func delete(entity: TodoEntity) async throws
    func update(entity: TodoEntity, title: String, notes: String, priority: PriorityEntity) async throws
}
