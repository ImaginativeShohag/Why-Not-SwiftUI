//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

@MainActor
class TodoHomeViewModel: ObservableObject {
    @Published var todoList: [Todo] = []
    @Published var showCompletedItems = false
    @Published var sortToShowLatestFirst = true

    private let sourceTodoList = (1 ... 100).map {
        Todo(
            title: "Task \($0)",
            notes: "Notes \($0)",
            priority: $0 % 2 == 0 ? .none : .medium,
            isCompleted: $0 % 2 == 0 ? true : false
        )
    }

    nonisolated init() {}

    func load() async {
        try? await Task.sleep(for: .seconds(1))

        updateList()
    }

    func add(title: String, notes: String, priority: TodoPriority) {
        if title.isEmpty, notes.isEmpty {
            return
        }

        todoList.append(
            Todo(
                title: title,
                notes: notes,
                priority: priority
            )
        )
    }

    func save(todo: Todo, title: String, notes: String, priority: TodoPriority) {
        if title.isEmpty, notes.isEmpty {
            return
        }

        todo.title = title
        todo.notes = notes
        todo.priority = priority
    }

    func changeShowCompletedItems() {
        self.showCompletedItems.toggle()
        
        updateList()
    }

    func changeSortToShowLatestFirst() {
        self.sortToShowLatestFirst.toggle()
        
        updateList()
    }

    private func updateList() {
        let items = sourceTodoList.filter { todo in
            if showCompletedItems {
                true
            } else {
                !todo.isCompleted
            }
        }

        if sortToShowLatestFirst {
            todoList = items.reversed()
        } else {
            todoList = items
        }
    }
}
