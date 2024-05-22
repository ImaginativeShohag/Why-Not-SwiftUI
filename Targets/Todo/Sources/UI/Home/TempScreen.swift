//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftData
import SwiftUI

#Preview {
    NavigationStack  {
        TempScreen()
    }
}

struct TempScreen: View {
    @State private var isPresented: Bool = false

    @Query(sort: \Todo.title, order: .reverse) private var todos: [Todo]

    var body: some View {
        VStack {
            ToDoListView(todos: todos)
                .navigationTitle("TODO App")
        }
        .background(Color.debugRandom)
        .sheet(isPresented: $isPresented, content: {
            AddToDoListItemScreen()
        })
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct ToDoDetailScreen: View {
    @State private var name: String = ""
    @State private var note: String = ""

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let todo: Todo

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Note description", text: $note)

            Button("Update") {
                todo.title = name
                todo.notes = note

                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }

                dismiss()
            }
        }
        .background(Color.debugRandom)
        .onAppear {
            name = todo.title
            note = todo.notes
        }
    }
}

struct ToDoListView: View {
    let todos: [Todo]
    @Environment(\.modelContext) private var context

    private func deleteTodo(indexSet: IndexSet) {
        for index in indexSet {
            let todo = todos[index]
            context.delete(todo)

            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    var body: some View {
        List {
            ForEach(todos, id: \.id) { todo in
//                NavigationLink(value: todo) {
//                    VStack(alignment: .leading) {
//                        Text(todo.title)
//                            .font(.title3)
//                        Text(todo.notes)
//                            .font(.caption)
//                    }
//                }

                NavigationLink {
                    ToDoDetailScreen(todo: todo)
                } label: {
                    VStack(alignment: .leading) {
                        Text(todo.title)
                            .font(.title3)
                        Text(todo.notes)
                            .font(.caption)
                    }
                    .background(Color.debugRandom)
                }
            }.onDelete(perform: deleteTodo)
        }
        .background(Color.debugRandom)
//        .navigationDestination(for: Todo.self) { todo in
//            ToDoDetailScreen(todo: todo)
//        }
    }
}

struct AddToDoListItemScreen: View {
    @State private var name = ""
    @State private var noteDiscription = ""

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    private var isFormValid: Bool {
        !name.isEmpty && !noteDiscription.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Enter Title", text: $name)
                TextField("Enter your notes", text: $noteDiscription)
                Button("Save") {
                    let todo = Todo(title: name, notes: noteDiscription, priority: .none)
                    context.insert(todo)
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    dismiss()
                }.disabled(!isFormValid)
            }
            .background(Color.debugRandom)
            .navigationTitle("Add todo item")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
