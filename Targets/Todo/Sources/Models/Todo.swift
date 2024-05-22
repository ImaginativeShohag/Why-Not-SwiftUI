//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftData
import SwiftUI

enum TodoPriority: Codable {
    case none, low, medium, high
}

@Model
class Todo {
    @Attribute(.unique) let id: Int
    var title: String
    var notes: String
    var priority: TodoPriority
    let createdAt: Date
    var isCompleted: Bool

    init(
        id: Int = UUID().hashValue,
        title: String,
        notes: String,
        priority: TodoPriority,
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
