//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct TodoEditSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State var title: String
    @State var notes: String
    @State var priority: TodoPriority

    let onSaveClick: (_ title: String, _ notes: String, _ priority: TodoPriority) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(...5)
                }

                Section {
                    Picker("Priority", selection: $priority) {
                        Text("None").tag(TodoPriority.none)
                        Divider()
                        Text("Low").tag(TodoPriority.low)
                        Text("Medium").tag(TodoPriority.medium)
                        Text("High").tag(TodoPriority.high)
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
                        onSaveClick(title, notes, priority)
                    } label: {
                        Text("Save")
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
            TodoEditSheet(
                title: "Lorem",
                notes: "Ipsum",
                priority: .none
            ) { _, _, _ in }
                .presentationDetents([.medium])
        })
}
