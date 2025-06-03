//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

extension UITodo {
    @MainActor
    @Observable
    final class Todo: Sendable, Identifiable {
        let id: Int
        let title: String
        let notes: String
        let priority: UITodo.Priority
        let createdAt: Date
        var isCompleted: Bool

        init(
            id: Int = UUID().hashValue,
            title: String,
            notes: String,
            priority: UITodo.Priority,
            createdAt: Date = Date(),
            isCompleted: Bool = false
        ) {
            self.id = id
            self.title = title
            self.notes = notes
            self.priority = priority
            self.createdAt = createdAt
            self.isCompleted = isCompleted
        }
    }
}

extension UITodo.Todo: Equatable {
    nonisolated static func == (lhs: UITodo.Todo, rhs: UITodo.Todo) -> Bool {
        lhs.id == rhs.id
    }
}
