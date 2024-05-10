//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

@MainActor
class TodoDetailViewModel: ObservableObject {
    @Published var todo: Todo? = nil

    nonisolated init() {}

    func getTodo(id: Int) async {
        try? await Task.sleep(for: .seconds(1))

        todo = Todo(title: "Lorem", notes: "Ipsum", priority: .medium)
    }
}
