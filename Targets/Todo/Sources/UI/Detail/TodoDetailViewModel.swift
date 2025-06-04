//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Observation
import SuperLog
import SwiftData
import SwiftUI
import SuperLog

@MainActor
@Observable
class TodoDetailViewModel {
    private(set) var todo: UITodo.Todo?

    private let repository: ITodoRepository

    init(
        repository: ITodoRepository = TodoRepository()
    ) {
        self.repository = repository
    }

    func getTodo(id: Int) async {
        SuperLog.d("id: \(id)")

        do {
            todo = try await repository.getBy(id: id)
        } catch {
            SuperLog.e("error: \(error.localizedDescription)")
        }
    }

    func delete() async {
        guard let todo else { return }

        do {
            try await repository.delete(todo: todo)
        } catch {
            SuperLog.e("error: \(error.localizedDescription)")
        }
    }
}
