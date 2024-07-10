//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct NewsHomeScreen: View {
    @State var viewModel = NewsHomeViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch viewModel.news {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case let .error(message):
                ContentUnavailableView(message, image: "newspaper")

            case let .data(newsList):
                List {
                    Text("Featured")
                        .font(.headline)

                    ScrollView(.horizontal) {
                        HStack(spacing: 16) {
                            ForEach(newsList.filter { $0.isFeatured }) { news in
                                NewsCardItemView(
                                    title: news.title,
                                    details: news.details,
                                    date: news.getPublishedAt()
                                )
                                .frame(width: 200)
                                .padding(.vertical)
                            }
                        }
                        .padding(.horizontal, 2)
                    }

                    Text("Latest")
                        .font(.headline)

                    ForEach(newsList) { news in
                        NewsItemView(
                            title: news.title,
                            details: news.details,
                            date: news.getPublishedAt()
                        )
                    }
                }
                .listStyle(.plain)
            }
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("News")
        .task {
            await viewModel.loadData()
        }
    }
}

private struct NewsItemView: View {
    let title: String
    let details: String
    let date: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(date?.timeIntervalSinceNow() ?? "N/A")
                .font(.caption)

            Text(details)
                .lineLimit(2)
        }
    }
}

private struct NewsCardItemView: View {
    let title: String
    let details: String
    let date: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(date?.timeIntervalSinceNow() ?? "N/A")
                .font(.caption)

            Text(details)
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
