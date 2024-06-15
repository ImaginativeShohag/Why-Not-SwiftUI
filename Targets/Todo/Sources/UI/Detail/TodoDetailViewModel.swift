//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

@MainActor
@Observable
class TodoDetailViewModel {
    var todo: Todo?

    private let repository: TodoRepository

    private var isPreview = false

    nonisolated init(
        repository: TodoRepository = TodoRepository()
    ) {
        self.repository = repository
    }

    func getTodo(id: Int) async {
        guard !isPreview else { return }

        todo = await repository.getBy(id: id)
    }
}

#if DEBUG

extension TodoDetailViewModel {
    convenience nonisolated init(forPreview: Bool) {
        self.init()

        Task { @MainActor in
            self.isPreview = true
            
            self.todo = Todo(title: "Lorem", notes: "Ipsum", priority: .high)
        }
    }
}

#endif
