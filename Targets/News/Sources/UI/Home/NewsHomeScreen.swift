//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct NewsHomeScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                Text("Featured")
                    .font(.headline)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        ForEach(1 ... 10, id: \.self) { _ in
                            NewsCardItemView()
                                .frame(width: 200)
                                .padding(.vertical)
                        }
                    }
                    .padding(.horizontal, 2)
                }

                Text("Latest")
                    .font(.headline)

                ForEach(1 ... 10, id: \.self) { _ in
                    NewsItemView()
                }
            }
            .listStyle(.plain)
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("News")
    }
}

private struct NewsItemView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                .font(.headline)

            Text("1 Jan 2050")
                .font(.caption)

            Text("sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                .lineLimit(2)
        }
    }
}

private struct NewsCardItemView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                .font(.headline)

            Text("1 Jan 2050")
                .font(.caption)

            Text("sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                .lineLimit(2)
        }
        .padding()
        .cornerRadius(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray, lineWidth: 5)
        }
    }
}

struct NewsHomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewsHomeScreen()
        }
    }
}
