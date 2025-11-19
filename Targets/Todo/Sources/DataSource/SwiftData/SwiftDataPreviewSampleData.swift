//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftData

#if DEBUG

enum SwiftDataPreviewSampleData {
    @MainActor
    static let container: ModelContainer = try! inMemoryContainer()

    @MainActor
    private static let inMemoryContainer: () throws -> ModelContainer = {
        let schema = Schema([SDTodo.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])

        // MARK: Generate Mock Data

        let sampleData: [any PersistentModel] = [
            SDTodo(id: 1, title: "Lorem 1", notes: "Ipsum 1", priority: .low),
            SDTodo(id: 2, title: "Lorem 2", notes: "Ipsum 2", priority: .medium),
            SDTodo(id: 3, title: "Lorem 3", notes: "Ipsum 3", priority: .high),
            SDTodo(id: 4, title: "Lorem 4", notes: "Ipsum 4", priority: .none),
            SDTodo(id: 5, title: "Lorem 5", notes: "Ipsum 1", priority: .low),
            SDTodo(id: 6, title: "Lorem 6", notes: "Ipsum 2", priority: .medium),
            SDTodo(id: 7, title: "Lorem 7", notes: "Ipsum 3", priority: .high),
            SDTodo(id: 8, title: "Lorem 8", notes: "Ipsum 4", priority: .none),
            SDTodo(id: 9, title: "Lorem 9", notes: "Ipsum 1", priority: .low),
            SDTodo(id: 10, title: "Lorem 10", notes: "Ipsum 2", priority: .medium),
            SDTodo(id: 11, title: "Lorem 11", notes: "Ipsum 3", priority: .high),
            SDTodo(id: 12, title: "Lorem 12", notes: "Ipsum 4", priority: .none)
        ]

        for sampleData in sampleData {
            container.mainContext.insert(sampleData)
        }

        // Note: Without manual saving, preview not working somehow!
        try? container.mainContext.save()

        return container
    }
}

#endif
