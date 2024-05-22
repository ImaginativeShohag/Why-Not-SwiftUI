//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

@MainActor
class TodoDetailViewModel: ObservableObject {
    @Published var todo: Todo? = nil

    private let repository = TodoRepository()

    private var isPreview = false

    nonisolated init() {}

    func getTodo(id: Int) async {
        guard !isPreview else { return }

        todo = await repository.getBy(id: id)
    }
}

#if DEBUG

extension TodoDetailViewModel {
    convenience nonisolated init(forPreview: Bool = true) {
        self.init()

        isPreview = true

        Task { @MainActor in
            self.todo = Todo(title: "Lorem", notes: "Ipsum", priority: .high)
        }
    }
}

#endif
