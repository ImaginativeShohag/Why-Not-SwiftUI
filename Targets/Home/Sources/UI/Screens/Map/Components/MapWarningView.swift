//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct MapWarningView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack {
            content()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow, lineWidth: 2)
        }
        .background(Color.yellow.opacity(0.25))
        .background(Color.systemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack {
        MapWarningView {
            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s")

            Button {
                //
            } label: {
                Text("Lorem Ipsum")
            }
        }
        .padding()

        MapWarningView {
            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s")

            Button {
                //
            } label: {
                Text("Lorem Ipsum")
            }
        }
        .padding()
    }
    .background(Color.blue)
}
