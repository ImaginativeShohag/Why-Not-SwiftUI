//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
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
    @State var viewModel = TodoHomeViewModel()

    @State var showAddSheet = false
    @State var editItem: Todo? = nil

    var body: some View {
        VStack {
            List(viewModel.todoList, id: \.id) { todo in
                TodoItemViewWrapped(
                    todo: todo,
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
                        viewModel.toggleTodoCompleteStatus(for: todo)
                    }
                )
            }
            .animation(.default, value: viewModel.todoList)
        }
        .background(Color.debugRandom)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.changeSortToShowLatestFirst()
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .background(Color.debugRandom)
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.changeShowCompletedItems()
                } label: {
                    Image(systemName: viewModel.showCompletedItems ? "checkmark.rectangle.stack.fill" : "checkmark.rectangle.stack")
                        .background(Color.debugRandom)
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
                        .background(Color.debugRandom)
                    }
                }
            }
        }
        .navigationTitle("Todo")
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
                        await viewModel.save(
                            todo: todo,
                            title: title,
                            notes: notes,
                            priority: priority
                        )
                    }
                }
            )
            .presentationDetents([.medium])
        }
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        TodoHomeScreen(
            viewModel: TodoHomeViewModel(forPreview: true)
        )
    }
}

#endif

struct TodoItemViewWrapped: View {
    var todo: Todo
    let onClick: () -> Void
    let onEditClick: () -> Void
    let onCompleteClick: () -> Void

    var body: some View {
        TodoItemView(
            title: todo.title,
            notes: todo.notes,
            priority: todo.priority,
            isCompleted: todo.isCompleted
        ) {
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
                    todo.isCompleted ? "Incomplete" : "Complete",
                    systemImage: todo.isCompleted ? "minus.square" : "checkmark.square"
                )
            }
            .tint(todo.isCompleted ? Color.red : Color.green)
        }
    }
}

struct TodoItemView: View {
    let title: String
    let notes: String
    let priority: TodoPriority
    let isCompleted: Bool
    let onClick: () -> Void

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
        .background(Color.debugRandom)
    }
}
