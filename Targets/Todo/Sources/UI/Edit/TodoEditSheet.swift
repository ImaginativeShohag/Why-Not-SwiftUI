//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct TodoEditSheet: View {
    @State var title: String
    @State var details: String
    let onSaveClick: (_ title: String, _ details: String) -> Void

    var body: some View {
        VStack {
            TextField("Title", text: $title)

            TextField("Details", text: $details)

            Spacer()

            Button {
                onSaveClick(title, details)
            } label: {
                Text("Save")
            }
        }
        .textFieldStyle(.roundedBorder)
        .padding()
    }
}

#Preview {
    VStack {}
        .sheet(isPresented: .constant(true), content: {
            NavigationStack {
                TodoEditSheet(
                    title: "Lorem",
                    details: "Ipsum"
                ) { _, _ in }
            }
            .presentationDetents([.height(150)])
        })
}
