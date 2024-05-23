//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftData

@DataActor
final class TodoDataSource {
    static let shared = TodoDataSource()

    private var _database: IDatabase?

    let container: ModelContainer = try! ModelContainer(for: Todo.self)
    var database: any IDatabase {
        if let task = _database {
            return task
        }

        let task = makeDatabase()

        _database = task

        return task
    }

    private func makeDatabase() -> any IDatabase {
        return Database(modelContainer: container)
    }

    private init() {}
}
