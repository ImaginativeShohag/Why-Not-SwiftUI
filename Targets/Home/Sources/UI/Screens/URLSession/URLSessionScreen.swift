//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class URLSession: BaseDestination {
        override public func getScreen() -> any View {
            URLSessionScreen()
        }
    }
}

// MARK: - UI

struct URLSessionScreen: View {
    @State private var viewModel: URLSessionViewModel

    init(viewModel: URLSessionViewModel = URLSessionViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                ProgressView()

            case .error(let message):
                ContentUnavailableView(
                    message,
                    systemImage: "exclamationmark.triangle"
                )

            case .data(let fruits):
                if fruits.isEmpty {
                    ContentUnavailableView(
                        "No fruit found.",
                        systemImage: "cube.box"
                    )
                } else {
                    List {
                        ForEach(fruits) { fruit in
                            NavigationLink {
                                ObjectDetailsScreen(
                                    icon: fruit.getEmoji(),
                                    name: fruit.getName(),
                                    color: fruit.getColor()
                                )
                            } label: {
                                Text(fruit.getEmoji() + " " + fruit.getName())
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("URLSession Example")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.getFruits()
        }
    }
}

#if DEBUG

#Preview("Loading") {
    NavigationStack {
        URLSessionScreen(
            viewModel: URLSessionViewModel(forPreview: true, isLoading: true)
        )
    }
}

#Preview("Success") {
    NavigationStack {
        URLSessionScreen(
            viewModel: URLSessionViewModel(forPreview: true)
        )
    }
}

#Preview("Success (No Data)") {
    NavigationStack {
        URLSessionScreen(
            viewModel: URLSessionViewModel(forPreview: true, hasData: false)
        )
    }
}

#Preview("Error") {
    NavigationStack {
        URLSessionScreen(
            viewModel: URLSessionViewModel(forPreview: true, isError: true)
        )
    }
}

#endif
