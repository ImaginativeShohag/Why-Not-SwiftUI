//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
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

@MainActor
struct TodoDetailScreen: View {
    @State private var viewModel: TodoDetailViewModel

    private let id: Int

    @MainActor
    init(
        viewModel: TodoDetailViewModel = TodoDetailViewModel(
            modelContainer: TodoDataSource.shared.modelContainer
        ),
        id: Int
    ) {
        self.viewModel = viewModel
        self.id = id
    }

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
        .navigationTitle(viewModel.todo?.title ?? "Loading...")
        .task {
            await viewModel.getTodo(id: id)
        }
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        TodoDetailScreen(
            viewModel: TodoDetailViewModel(
                modelContainer: PreviewSampleData.container
            ),
            id: 1
        )
    }
}

#endif
