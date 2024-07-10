//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct NewsDetailsScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.headline)

                Text("1 Jan 2050")
                    .font(.caption)

                Text("sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NewsDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewsDetailsScreen()
        }
    }
}

