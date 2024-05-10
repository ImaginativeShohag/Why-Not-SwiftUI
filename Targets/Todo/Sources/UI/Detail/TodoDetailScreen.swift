//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class TodoDetail: BaseDestination {
        let id: Int

        init(id: Int) {
            self.id = id
        }

        override public func getScreen() -> any View {
            TodoDetailScreen(
                id: id
            )
        }
    }
}

// MARK: - UI

struct TodoDetailScreen: View {
    @StateObject var viewModel = TodoDetailViewModel()

    let id: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let todo = viewModel.todo {
                    var priorityCaption: String {
                        switch todo.priority {
                        case .none:
                            "None"
                        case .low:
                            "Low"
                        case .medium:
                            "Medium"
                        case .high:
                            "High"
                        }
                    }

                    var priorityColor: Color {
                        switch todo.priority {
                        case .none:
                            Color.clear
                        case .low:
                            Color.green
                        case .medium:
                            Color.yellow
                        case .high:
                            Color.red
                        }
                    }

                    HStack {
                        priorityColor
                            .frame(width: 16, height: 16)
                            .cornerRadius(8)

                        Text(priorityCaption)
                    }
                    .font(.subheadline)

                    if !todo.notes.isEmpty {
                        Text(todo.notes)
                            .font(.headline)
                    }

                    Text("The task is \(todo.isCompleted ? "completed" : "not completed").")
                        .font(.footnote)
                } else {
                    Text("Loading...")
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.debugRandom)
        .navigationTitle(viewModel.todo?.title ?? "Loading...")
        .task {
            await viewModel.getTodo(id: id)
        }
    }
}

#Preview {
    NavigationStack {
        TodoDetailScreen(
            id: UUID().hashValue
        )
    }
}
