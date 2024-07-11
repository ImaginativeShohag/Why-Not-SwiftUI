//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Kingfisher
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class NewsHome: BaseDestination {
        override public func getScreen() -> any View {
            NewsHomeScreen()
        }
    }
}

// MARK: - UI

@MainActor
struct NewsHomeScreen: View {
    @State var viewModel: NewsHomeViewModel

    init(viewModel: NewsHomeViewModel = NewsHomeViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    Text("🥭 News")
                    Text(Date().toString(dateFormat: "MMMM d") ?? "N/A")
                        .accessibilityIdentifier("headline_date")
                        .foregroundStyle(.gray)
                }
                .font(.system(.title, weight: .heavy))
                .padding(.horizontal)

                Divider()
                    .padding(.vertical)

                switch viewModel.news {
                case .loading:
                    ProgressView()
                        .accessibilityIdentifier("loading_container")
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .center
                        )

                case let .error(message):
                    ContentUnavailableView(message, systemImage: "exclamationmark.triangle")
                        .accessibilityIdentifier("error_container")

                case let .data(newsList):
                    LazyVStack(alignment: .leading, spacing: 16) {
                        let featuredNews = newsList.filter { $0.isFeatured }

                        if !featuredNews.isEmpty {
                            Text("Top Stories")
                                .accessibilityIdentifier("headline_featured")
                                .font(.system(.title, weight: .heavy))
                                .foregroundStyle(.red)
                                .padding(.horizontal)

                            ScrollView(.horizontal) {
                                HStack(spacing: 16) {
                                    ForEach(featuredNews) { news in
                                        NavigationLink(
                                            destination: Destination.NewsDetails(news: news)
                                        ) {
                                            NewsCardItemView(
                                                title: news.title,
                                                details: news.details,
                                                date: news.getPublishedAt(),
                                                thumbnail: news.thumbnail
                                            )
                                        }
                                        .accessibilityIdentifier("featured_news_item_\(news.id)")
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .accessibilityIdentifier("featured")
                            .scrollClipDisabled()
                            .scrollIndicators(.hidden)
                        }

                        Text("Latest")
                            .accessibilityIdentifier("headline_latest")
                            .font(.system(.title, weight: .black))
                            .padding(.horizontal)

                        ForEach(newsList) { news in
                            NavigationLink(
                                destination: Destination.NewsDetails(news: news)
                            ) {
                                NewsItemView(
                                    title: news.title,
                                    details: news.details,
                                    date: news.getPublishedAt(),
                                    thumbnail: news.thumbnail
                                )
                            }
                            .accessibilityIdentifier("news_item_\(news.id)")
                        }
                        .padding(.horizontal)
                    }

                    .buttonStyle(.plain)
                }
            }
        }
        .refreshable {
            if !viewModel.news.isLoading {
                await viewModel.loadData(forced: true)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}

@MainActor
private struct NewsItemView: View {
    let title: String
    let details: String
    let date: Date?
    let thumbnail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NewsThumbnail(url: thumbnail)
                .accessibilityIdentifier("thumbnail")

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .accessibilityIdentifier("title")
                    .font(.system(.headline, weight: .heavy))

                Text(date?.timeIntervalSinceNow() ?? "N/A")
                    .accessibilityIdentifier("published_date")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 4)
    }
}

@MainActor
private struct NewsCardItemView: View {
    let title: String
    let details: String
    let date: Date?
    let thumbnail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NewsThumbnail(url: thumbnail)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(.headline, weight: .heavy))

                Text(date?.timeIntervalSinceNow() ?? "N/A")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.2), radius: 4)
        .frame(width: 200)
    }
}

#if DEBUG

#Preview("Loading") {
    NavigationStack {
        NewsHomeScreen(
            viewModel: NewsHomeViewModel(forPreview: true, isLoading: true)
        )
    }
}

#Preview("Success") {
    NavigationStack {
        NewsHomeScreen(
            viewModel: NewsHomeViewModel(forPreview: true)
        )
    }
}

#Preview("Success (without featured)") {
    NavigationStack {
        NewsHomeScreen(
            viewModel: NewsHomeViewModel(forPreview: true, showFeatured: false)
        )
    }
}

#Preview("Error") {
    NavigationStack {
        NewsHomeScreen(
            viewModel: NewsHomeViewModel(forPreview: true, isError: true)
        )
    }
}

#endif
