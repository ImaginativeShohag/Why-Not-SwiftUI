//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Foundation
import SuperLog
import SwiftData
import SwiftUI

@MainActor
@Observable
class TodoHomeViewModel {
    private(set) var todoList: [UITodo.Todo] = []
    private(set) var showCompletedItems = Preferences.showCompletedItems ?? false
    private(set) var sortToShowLatestFirst = Preferences.sortToShowLatestFirst ?? true
    private(set) var selectedPriority: UITodo.Priority = .none

    private let repository: ITodoRepository

    private var isPreview = false

    private var sourceTodoList: [UITodo.Todo] = []

    init(
        repository: ITodoRepository = TodoRepository()
    ) {
        self.repository = repository
    }

    func load() async {
        guard !isPreview else { return }

        sourceTodoList = await repository.getAll()

        SuperLog.v(sourceTodoList)

        updateList()
    }

    func add(
        title: String,
        notes: String,
        priority: UITodo.Priority
    ) async {
        if title.isEmpty, notes.isEmpty {
            return
        }

        let todo = UITodo.Todo(
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

        // Reload Data
        await load()
    }

    func update(
        todo: UITodo.Todo,
        title: String,
        notes: String,
        priority: UITodo.Priority,
        isCompleted: Bool
    ) async {
        if title.isEmpty, notes.isEmpty {
            return
        }

        do {
            try await repository.update(
                id: todo.id,
                title: title,
                notes: notes,
                priority: priority,
                isCompleted: isCompleted
            )

            // Update the model
            todo.title = title
            todo.notes = notes
            todo.priority = priority
            todo.isCompleted = isCompleted
        } catch {
            SuperLog.e("error: \(error)")
        }
    }

    func changeShowCompletedItems() {
        showCompletedItems.toggle()
        
        Preferences.showCompletedItems = showCompletedItems

        updateList()
    }

    func changeSortToShowLatestFirst() {
        sortToShowLatestFirst.toggle()
        
        Preferences.sortToShowLatestFirst = sortToShowLatestFirst

        updateList()
    }

    func toggleTodoCompleteStatus(for todo: UITodo.Todo) async {
        let isCompleted = !todo.isCompleted

        do {
            try await repository.update(
                id: todo.id,
                title: todo.title,
                notes: todo.notes,
                priority: todo.priority,
                isCompleted: isCompleted
            )

            // Update the model
            todo.isCompleted = isCompleted
            
            // Update the list
            if todo.isCompleted, !showCompletedItems, let index = todoList.firstIndex(of: todo) {
                todoList.remove(at: index)
            }
        } catch {
            SuperLog.e("error: \(error)")
        }
    }
    
    func updatePriorityFilter(priority: UITodo.Priority) {
        selectedPriority = priority

        updateList()
    }

    func updateList() {
        var items = sourceTodoList.filter { todo in
            if showCompletedItems {
                true
            } else {
                !todo.isCompleted
            }
        }

        // Filter by priority
        if selectedPriority != .none {
            items = items.filter { $0.priority == selectedPriority }
        }

        // Sort
        if sortToShowLatestFirst {
            todoList = items.reversed()
        } else {
            todoList = items
        }
    }
}

#if DEBUG

extension TodoHomeViewModel {
    convenience init(
        forPreview: Bool,
        isEmpty: Bool = false
    ) {
        self.init(
            repository: MockTodoRepository()
        )

        self.isPreview = true

        if !isEmpty {
            self.sourceTodoList = (1 ... 100).map {
                UITodo.Todo(
                    title: "Task \($0)",
                    notes: "Notes \($0)",
                    priority: $0 % 2 == 0 ? .none : ($0 % 3 == 0 ? .medium : .high),
                    isCompleted: Bool.random()
                )
            }
        }

        updateList()
    }
}

#endif
