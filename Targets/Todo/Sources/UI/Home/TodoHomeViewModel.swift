//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import SuperLog
import SwiftData
import SwiftUI

@Observable
class TodoHomeViewModel {
    private(set) var todoList: [Todo] = []
    private(set) var showCompletedItems = false
    private(set) var sortToShowLatestFirst = true

    private let repository: TodoRepository

    private var isPreview = false

    private var sourceTodoList: [Todo] = []

    init(
        modelContainer: ModelContainer
    ) {
        self.repository = TodoRepository(modelContainer: modelContainer)
    }

    func load() async {
        guard !isPreview else { return }
        guard todoList.isEmpty else { return }

        sourceTodoList = await repository.getAll()

        updateList()
    }

    func add(title: String, notes: String, priority: TodoPriority) async {
        if title.isEmpty, notes.isEmpty {
            return
        }

        let todo = Todo(
            title: title,
            notes: notes,
            priority: priority
        )

        do {
            try await repository.insert(todo: todo)

            sourceTodoList.append(todo)
        } catch {
            SuperLog.d("error: \(error)")
        }

        updateList()
    }

    func save(todo: Todo, title: String, notes: String, priority: TodoPriority) async {
        if title.isEmpty, notes.isEmpty {
            return
        }

        do {
            try await repository.update(
                todo: todo,
                title: title,
                notes: notes,
                priority: priority
            )
        } catch {
            SuperLog.d("error: \(error)")
        }
    }

    func changeShowCompletedItems() {
        showCompletedItems.toggle()

        updateList()
    }

    func changeSortToShowLatestFirst() {
        sortToShowLatestFirst.toggle()

        updateList()
    }

    func toggleTodoCompleteStatus(for todo: Todo) {
        todo.isCompleted.toggle()

        if todo.isCompleted, !showCompletedItems, let index = todoList.firstIndex(of: todo) {
            todoList.remove(at: index)
        }
    }

    func updateList() {
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

#if DEBUG

extension TodoHomeViewModel {
    convenience init(forPreview: Bool) {
        self.init(
            modelContainer: PreviewSampleData.container
        )

        SuperLog.d("hi")

        self.isPreview = true

        self.sourceTodoList = (1 ... 100).map {
            Todo(
                title: "Task \($0)",
                notes: "Notes \($0)",
                priority: $0 % 2 == 0 ? .none : .medium,
                isCompleted: $0 % 2 == 0 ? true : false
            )
        }

        updateList()
    }
}

#endif
