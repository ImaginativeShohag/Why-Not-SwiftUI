//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

@MainActor
class TodoHomeViewModel: ObservableObject {
    @Published var todoList: [Todo] = (1 ... 100).map {
        Todo(
            title: "Task \($0)",
            details: "Details \($0)",
            isCompleted: $0 % 2 == 0 ? true : false
        )
    }

    nonisolated init() {}

    func add(title: String, details: String) {
        if title.isEmpty, details.isEmpty {
            return
        }

        todoList.append(
            Todo(title: title, details: details)
        )
    }

    func save(todo: Todo, title: String, details: String) {
        if title.isEmpty, details.isEmpty {
            return
        }

        todo.title = title
        todo.details = details
    }
}
