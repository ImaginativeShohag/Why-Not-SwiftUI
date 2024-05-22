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
                        if todo.priority != .none {
                            priorityColor
                                .frame(width: 16, height: 16)
                                .cornerRadius(8)
                        }

                        Text(priorityCaption)
                    }
                    .monospaced()
                    .font(.footnote)
                    .padding(6)
                    .background(Color.secondarySystemBackground)
                    .containerShape(Capsule())

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
            viewModel: TodoDetailViewModel(forPreview: true),
            id: UUID().hashValue
        )
    }
}
