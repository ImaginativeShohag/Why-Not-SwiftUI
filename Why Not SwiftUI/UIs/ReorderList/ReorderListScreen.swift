//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI
import SwiftUIIntrospect

/// Resources:
/// - [How to Reorder List rows in SwiftUI List](https://sarunw.com/posts/swiftui-list-onmove/)

struct ReorderListScreen: View {
    @State var editMode = EditMode.inactive
    @State private var contacts = [
        "John",
        "Alice",
        "Bob",
        "Foo",
        "Bar"
    ]

    var body: some View {
        List {
            ForEach(Array(contacts.enumerated()), id: \.offset) { index, contact in
                HStack {
                    Text("\(index + 1)")
                        .frame(minWidth: 16)
                        .padding(4)
                        .foregroundColor(.white)
                        .background(Color.primary)
                        .cornerRadius(8)

                    Text(contact)
                        .listRowSeparator(.hidden)
                }
            }
            .onMove { indices, newOffset in
                contacts.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .onAppear {
            editMode = .active
        }
    }
}

#Preview {
    NavigationStack {
        ReorderListScreen()
    }
}
