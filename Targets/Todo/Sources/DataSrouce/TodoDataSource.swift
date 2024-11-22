//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftData

final actor TodoDataSource {
    static let shared = TodoDataSource()

    let container: ModelContainer = try! ModelContainer(for: Todo.self)
    nonisolated lazy var modelContainer: ModelContainer = {
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(for: Todo.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
        return modelContainer
    }()

    private init() {}
}
