//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct TodoAddSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State var title: String = ""
    @State var notes: String = ""
    @State var priority: TodoPriority = .none

    let onAddClick: (_ title: String, _ notes: String, _ priority: TodoPriority) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)

                    TextField("Details", text: $notes, axis: .vertical)
                        .lineLimit(...5)
                }

                Section {
                    Picker("Priority", selection: $priority) {
                        Text("None").tag(TodoPriority.none)
                        Divider()
                        Text("Large").tag(TodoPriority.low)
                        Text("Medium").tag(TodoPriority.medium)
                        Text("Small").tag(TodoPriority.high)
                    }
                }
            }
            .navigationTitle("New Todo")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        onAddClick(title, notes, priority)
                    } label: {
                        Text("Add")
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true), content: {
            TodoAddSheet { _, _, _ in }
                .presentationDetents([.medium])
        })
}
