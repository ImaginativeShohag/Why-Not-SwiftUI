//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class Alamofire: BaseDestination {
        override public func getScreen() -> any View {
            AlamofireScreen()
        }
    }
}

// MARK: - UI

struct AlamofireScreen: View {
    @State private var viewModel: AlamofireViewModel

    init(viewModel: AlamofireViewModel = AlamofireViewModel()) {
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
                                Text(fruit.getName())
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Alamofire Example")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.getFlowers()
        }
    }
}

#if DEBUG

#Preview("Loading") {
    NavigationStack {
        AlamofireScreen(
            viewModel: AlamofireViewModel(forPreview: true, isLoading: true)
        )
    }
}

#Preview("Success") {
    NavigationStack {
        AlamofireScreen(
            viewModel: AlamofireViewModel(forPreview: true)
        )
    }
}

#Preview("Success (No Data)") {
    NavigationStack {
        AlamofireScreen(
            viewModel: AlamofireViewModel(forPreview: true, hasData: false)
        )
    }
}

#Preview("Error") {
    NavigationStack {
        AlamofireScreen(
            viewModel: AlamofireViewModel(forPreview: true, isError: true)
        )
    }
}

#endif
