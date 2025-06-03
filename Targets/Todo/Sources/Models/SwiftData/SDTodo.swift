//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftData
import SwiftUI

@Model
final class SDTodo: Sendable {
    @Attribute(.unique) var id: Int
    var title: String
    var notes: String
    var priority: SDPriority
    var createdAt: Date
    var isCompleted: Bool

    init(
        id: Int = UUID().hashValue,
        title: String,
        notes: String,
        priority: SDPriority,
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

// MARK: - Extensions

extension SDTodo {
    func toUIModel() async -> UITodo.Todo {
        await .init(
            id: id,
            title: title,
            notes: notes,
            priority: priority.toUIModel(),
            createdAt: createdAt,
            isCompleted: isCompleted
        )
    }
}
