//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import SwiftUI

@MainActor
class TodoHomeViewModel: ObservableObject {
    @Published var todoList: [Todo] = []
    @Published var showCompletedItems = false
    @Published var sortToShowLatestFirst = true

    private let repository = TodoRepository()

    private var isPreview = false

    private var sourceTodoList: [Todo] = []

    nonisolated init() {}

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
    convenience nonisolated init(forPreview: Bool = true) {
        self.init()

        isPreview = true

        Task { @MainActor in
            sourceTodoList = (1 ... 100).map {
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
}

#endif
