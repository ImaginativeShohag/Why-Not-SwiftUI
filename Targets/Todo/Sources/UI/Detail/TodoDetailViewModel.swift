//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Observation
import SwiftData
import SwiftUI

@MainActor
@Observable
class TodoDetailViewModel {
    var todo: UITodo.Todo?

    private let repository: ITodoRepository

    private var isPreview = false

    init(
        repository: ITodoRepository = TodoRepository()
    ) {
        self.repository = repository
    }

    func getTodo(id: Int) async {
        guard !isPreview else { return }

        todo = await repository.getBy(id: id)
    }
}
