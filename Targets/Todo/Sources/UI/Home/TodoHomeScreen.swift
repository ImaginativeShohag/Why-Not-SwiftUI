//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
import SwiftData
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class TodoHome: BaseDestination {
        override public func getScreen() -> any View {
            TodoHomeScreen()
        }
    }
}

// MARK: - UI

struct TodoHomeScreen: View {
    @State private var viewModel: TodoHomeViewModel
    @State private var showAddSheet = false
    @State private var editItem: UITodo.Todo? = nil

    init(
        viewModel: TodoHomeViewModel = TodoHomeViewModel()
    ) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(UITodo.Priority.allCases, id: \.self) { priority in
                    Button {
                        viewModel.updatePriorityFilter(priority: priority)
                    } label: {
                        Text(priority == .none ? "All" : priority.description)
                            .bold(viewModel.selectedPriority == priority)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(viewModel.selectedPriority == priority ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()

            if viewModel.todoList.isEmpty {
                ContentUnavailableView(
                    "Nothing here yet!",
                    systemImage: "heart.text.clipboard",
                    description: Text("Your todo will appear here.")
                )
            } else {
                List(viewModel.todoList, id: \.id) { todo in
                    TodoItemView(
                        title: todo.title,
                        notes: todo.notes,
                        priority: todo.priority,
                        isCompleted: todo.isCompleted,
                        onClick: {
                            NavController.shared.navigateTo(
                                Destination.TodoDetail(
                                    id: todo.id
                                )
                            )
                        },
                        onEditClick: {
                            editItem = todo
                        },
                        onCompleteClick: {
                            Task {
                                await viewModel.toggleTodoCompleteStatus(for: todo)
                            }
                        }
                    )
                }
            }
        }
        .animation(.default, value: viewModel.todoList)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.changeSortToShowLatestFirst()
                } label: {
                    Image(systemName: viewModel.sortToShowLatestFirst ? "arrow.up.arrow.down.circle.fill" : "arrow.up.arrow.down.circle")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.changeShowCompletedItems()
                } label: {
                    Image(systemName: viewModel.showCompletedItems ? "checkmark.rectangle.stack.fill" : "checkmark.rectangle.stack")
                }
            }

            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button {
                        showAddSheet.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")

                            Text("New Todo")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle("Todo")
        .toolbarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $showAddSheet) {
            TodoAddSheet(
                onAddClick: { title, notes, priority in
                    showAddSheet.toggle()

                    Task {
                        await viewModel.add(
                            title: title,
                            notes: notes,
                            priority: priority
                        )
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(item: $editItem) { todo in
            TodoEditSheet(
                title: todo.title,
                notes: todo.notes,
                priority: todo.priority,
                onSaveClick: { title, notes, priority in
                    editItem = nil

                    Task {
                        await viewModel.update(
                            todo: todo,
                            title: title,
                            notes: notes,
                            priority: priority,
                            isCompleted: false
                        )
                    }
                }
            )
            .presentationDetents([.medium])
        }
    }
}

#if DEBUG

#Preview("With Data") {
    NavigationStack {
        TodoHomeScreen(
            viewModel: TodoHomeViewModel(
                forPreview: true
            )
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        TodoHomeScreen(
            viewModel: TodoHomeViewModel(
                forPreview: true,
                isEmpty: true
            )
        )
    }
}

#endif

// MARK: - Components

private struct TodoItemView: View {
    let title: String
    let notes: String
    let priority: UITodo.Priority
    let isCompleted: Bool

    let onClick: () -> Void
    let onEditClick: () -> Void
    let onCompleteClick: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)

                Text(notes)
                    .font(.body)
                    .lineLimit(...2)
            }

            Spacer()

            Group {
                switch priority {
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
            .frame(width: 16, height: 16)
            .cornerRadius(8)
        }
        .contentShape(Rectangle())
        .strikethrough(isCompleted)
        .onTapGesture {
            onClick()
        }
        .swipeActions(edge: .leading) {
            Button {
                onEditClick()
            } label: {
                Label(
                    "Edit",
                    systemImage: "square.and.pencil"
                )
            }
            .tint(Color.blue)
        }
        .swipeActions(edge: .trailing) {
            Button {
                onCompleteClick()
            } label: {
                Label(
                    isCompleted ? "Incomplete" : "Complete",
                    systemImage: isCompleted ? "minus.square" : "checkmark.square"
                )
            }
            .tint(isCompleted ? Color.red : Color.green)
        }
    }
}
