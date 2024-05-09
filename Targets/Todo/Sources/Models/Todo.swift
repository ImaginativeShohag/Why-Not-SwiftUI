//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

class Todo: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String
    @Published var details: String
    let createdAt: Date
    @Published var isCompleted: Bool

    init(
        title: String,
        details: String,
        createdAt: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.title = title
        self.details = details
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
}
