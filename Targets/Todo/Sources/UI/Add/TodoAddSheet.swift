//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct TodoAddSheet: View {
    @State var title: String = ""
    @State var details: String = ""

    let onAddClick: (_ title: String, _ details: String) -> Void

    var body: some View {
        VStack {
            TextField("Title", text: $title)

            TextField("Details", text: $details)

            Spacer()

            Button {
                onAddClick(title, details)
            } label: {
                Text("Add")
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
                TodoAddSheet { _, _ in }
            }
            .presentationDetents([.height(150)])
        })
}
