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
    @StateObject var viewModel = TodoHomeViewModel()

    @State var showAddSheet = false
    @State var editItem: Todo? = nil
    @State var showCompleted = false

    var body: some View {
        VStack {
            List(viewModel.todoList.filter { todo in
                if showCompleted {
                    true
                } else {
                    !todo.isCompleted
                }
            }.reversed()) { todo in
                TodoItemViewWrapped(
                    todo: todo,
                    onClick: {
                        //
                    },
                    onEditClick: {
                        editItem = todo
                    }
                )
            }
        }
        .background(Color.debugRandom)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showCompleted.toggle()
                } label: {
                    Image(systemName: showCompleted ? "checkmark.rectangle.stack.fill" : "checkmark.rectangle.stack")
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
                        .background(Color.debugRandom)
                    }

                    Spacer()
                }
            }
        }
        .navigationTitle("Todo")
        .sheet(isPresented: $showAddSheet) {
            TodoAddSheet(
                onAddClick: { title, details in
                    showAddSheet.toggle()

                    viewModel.add(title: title, details: details)
                }
            )
            .presentationDetents([.height(150)])
        }
        .sheet(item: $editItem) { todo in
            TodoEditSheet(
                title: todo.title,
                details: todo.details,
                onSaveClick: { title, details in
                    editItem = nil

                    viewModel.save(
                        todo: todo,
                        title: title,
                        details: details
                    )
                }
            )
            .presentationDetents([.height(150)])
        }
    }
}

#Preview {
    NavigationStack {
        TodoHomeScreen()
    }
}

struct TodoItemViewWrapped: View {
    @ObservedObject var todo: Todo
    let onClick: () -> Void
    let onEditClick: () -> Void

    var body: some View {
        TodoItemView(
            title: todo.title,
            details: todo.details,
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
                todo.isCompleted.toggle()
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
    let details: String
    let isCompleted: Bool
    let onClick: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)

            Text(details)
                .font(.body)
        }
        .strikethrough(isCompleted)
        .background(Color.debugRandom)
    }
}
