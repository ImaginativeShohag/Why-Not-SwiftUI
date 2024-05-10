//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

class Todo: ObservableObject, Identifiable {
    let id: Int
    @Published var title: String
    @Published var notes: String
    @Published var priority: TodoPriority
    let createdAt: Date
    @Published var isCompleted: Bool

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

enum TodoPriority {
    case none, low, medium, high
}
