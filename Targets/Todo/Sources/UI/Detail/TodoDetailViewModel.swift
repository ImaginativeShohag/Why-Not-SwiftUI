//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Observation
import SwiftData
import SwiftUI

@Observable
class TodoDetailViewModel {
    var todo: Todo?

    private let repository: TodoRepository

    private var isPreview = false

    init(
        modelContainer: ModelContainer
    ) {
        self.repository = TodoRepository(modelContainer: modelContainer)
    }

    func getTodo(id: Int) async {
        guard !isPreview else { return }

        todo = await repository.getBy(id: id)
    }
}
