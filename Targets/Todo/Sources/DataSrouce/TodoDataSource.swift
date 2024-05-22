//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftData

class TodoDataSource {
    static let shared = TodoDataSource()

    private var _database: Task<IDatabase, Never>?

    let container: ModelContainer = try! ModelContainer(for: Todo.self)
    var database: any IDatabase {
        get async {
            if let task = _database {
                return await task.value
            }

            let task = Task { await makeDatabase() }

            self._database = task

            return await task.value
        }
    }
    
    private func makeDatabase() async -> any IDatabase {
        return Database(modelContainer: container)
    }

    private init() {}
}
