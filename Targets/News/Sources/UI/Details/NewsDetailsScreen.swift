//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Kingfisher
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class NewsDetails: BaseDestination {
        let news: News

        init(news: News) {
            self.news = news
        }

        override public func getScreen() -> any View {
            NewsDetailsScreen(
                news: news
            )
        }
    }
}

// MARK: - UI

@MainActor
struct NewsDetailsScreen: View {
    let news: News

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                NewsThumbnail(url: news.thumbnail)
                    .accessibilityIdentifier("thumbnail")
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.bottom)

                Text(news.title)
                    .accessibilityIdentifier("title")
                    .font(.system(.title, weight: .heavy))

                Text(news.getPublishedAt()?.timeIntervalSinceNow() ?? "N/A")
                    .accessibilityIdentifier("published_date")
                    .font(.callout)
                    .foregroundStyle(.gray)

                Text(news.details)
                    .accessibilityIdentifier("details")

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG

struct NewsDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewsDetailsScreen(
                news: News.mockItem()
            )
        }
    }
}

#endif
