//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Kingfisher
import NavigationKit
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

                switch viewModel.newsState {
                case .loading:
                    ProgressView()
                        .accessibilityIdentifier("loading_container")
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .center
                        )

                    Spacer()

                case let .error(message):
                    ContentUnavailableView(label: {
                        Label(message, systemImage: "exclamationmark.triangle")
                            .accessibilityIdentifier("error_container")
                    }, description: {
                        Text("Cannot load news from server.")
                    }, actions: {
                        Button(action: {
                            Task {
                                await viewModel.loadData(forced: true)
                            }
                        }) {
                            Text("Retry")
                        }
                    })

                case let .data(newsList):
                    if newsList.isEmpty {
                        ContentUnavailableView(label: {
                            Label(
                                "No news yet!",
                                systemImage: "newspaper"
                            )
                        }, description: {
                            Text("No news found on the server.")
                        }, actions: {
                            Button(action: {
                                Task {
                                    await viewModel.loadData(forced: true)
                                }
                            }) {
                                Text("Refresh")
                            }
                        })
                        .accessibilityIdentifier("empty_container")
                    } else {
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

                            NewsTypesSectionView(
                                types: viewModel.typesState,
                                onRetryClick: {
                                    Task {
                                        await viewModel.loadTypes()
                                    }
                                },
                                onClick: { _ in
                                    //
                                }
                            )

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

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            if !viewModel.newsState.isLoading {
                await viewModel.loadData(forced: true)
                await viewModel.loadTypes()
            }
        }
        .task {
            await viewModel.loadData()
            await viewModel.loadTypes()
        }
    }
}

struct NewsTypesSectionView: View {
    let types: UIState<[NewsType]>
    let onRetryClick: () -> Void
    let onClick: (NewsType) -> Void

    var body: some View {
        HStack(alignment: .center) {
            switch types {
            case .loading:
                ProgressView()

            case let .error(message):
                VStack {
                    Text(message)

                    Button {
                        onRetryClick()
                    } label: {
                        Text("Retry")
                    }
                    .buttonStyle(.bordered)
                }

            case let .data(types):
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(types, id: \.id) { type in
                            Button {
                                onClick(type)
                            } label: {
                                Text(type.name)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.systemGroupedBackground)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.randomSystemColor, lineWidth: 4)
                                    )
                            }
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity)
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

#Preview("Success (with news type error)") {
    NavigationStack {
        NewsHomeScreen(
            viewModel: NewsHomeViewModel(forPreview: true, isNewsTypeError: true)
        )
    }
}

#Preview("Success (No News)") {
    NavigationStack {
        NewsHomeScreen(
            viewModel: NewsHomeViewModel(forPreview: true, hasNews: false)
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
