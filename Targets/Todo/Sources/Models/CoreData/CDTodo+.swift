//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CoreData

extension CDTodo {
    var priority: CDTodoPriority {
        get {
            CDTodoPriority(rawValue: self.priorityValue) ?? .medium
        }
        set {
            self.priorityValue = newValue.rawValue
        }
    }
}

extension CDTodo {
    static func create(
        context: NSManagedObjectContext,
        id: Int = UUID().hashValue,
        title: String,
        notes: String,
        priority: CDTodoPriority,
        isCompleted: Bool,
        createdAt: Date = Date()
    ) -> CDTodo {
        let todo = CDTodo(context: context)

        todo.id = Int64(id)
        todo.title = title
        todo.notes = notes
        todo.priority = priority
        todo.isCompleted = isCompleted
        todo.createdAt = createdAt
        
        return todo
    }
}


// MARK: - Extensions

extension CDTodo {
    func toUIModel() async -> UITodo.Todo {
        await .init(
            id: Int(id),
            title: title ?? "",
            notes: notes ?? "",
            priority: priority.toUIModel(),
            createdAt: createdAt ?? Date(),
            isCompleted: isCompleted
        )
    }
}
