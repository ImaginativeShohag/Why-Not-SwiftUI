//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Kingfisher
import LocalizeKit
import NavigationKit
import SwiftUI

struct CategoriesScreen: View {
    @State var viewModel: CategoriesViewModel

    init(viewModel: CategoriesViewModel = CategoriesViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationViewStack {
            ZStack {
                switch viewModel.state {
                    case .loading:
                        ProgressView()

                    case .error(let message):
                        ContentUnavailableView(
                            label: {
                                Label(message, systemImage: "exclamationmark.triangle")
                            },
                            actions: {
                                Button("store_retry".localize(default: "Retry", comment: "Retry button text")) {
                                    Task {
                                        await viewModel.loadProducts(forced: true)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.top)
                            }
                        )

                    case .data(let categories):
                        ScrollView {
                            LazyVGrid(
                                columns: Array(repeating: .init(spacing: 8), count: 2),
                                spacing: 8
                            ) {
                                ForEach(categories, id: \.self) { category in
                                    Button {
                                        NavController.shared.navigateTo(
                                            Destination.Products(categoryId: category)
                                        )
                                    } label: {
                                        GeometryReader { proxy in
                                            ZStack {
                                                Text(category.capitalized)
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(.white)
                                                    .multilineTextAlignment(.center)
                                                    .shadow(
                                                        color: Color.black.opacity(0.5),
                                                        radius: 8,
                                                        x: 1,
                                                        y: 2
                                                    )
                                                    .padding()
                                                    .background(
                                                        .ultraThinMaterial,
                                                        in: RoundedRectangle(cornerRadius: 16)
                                                    )
                                            }
                                            .padding()
                                            .frame(
                                                width: proxy.size.width,
                                                height: proxy.size.height
                                            )
                                        }
                                        .frame(maxWidth: .infinity)
                                        .aspectRatio(1, contentMode: .fill)
                                        .background {
                                            KFImage(URL(string: "https://picsum.photos/seed/\(category)/300/300"))
                                                .placeholder {
                                                    Color.secondarySystemGroupedBackground
                                                }
                                                .resizable()
                                                .scaledToFit()
                                                .frame(
                                                    maxWidth: .infinity,
                                                    maxHeight: .infinity
                                                )
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.systemGroupedBackground)
            .navigationTitle("store_categories_title".localize(default: "Categories", comment: "Categories screen title"))
            .refreshable {
                await viewModel.loadProducts(forced: true)
            }
            .task {
                await viewModel.loadProducts()
            }
            .onLanguageChange()
        }
    }
}

#if DEBUG

#Preview("With Data") {
    NavigationStack {
        CategoriesScreen(
            viewModel: .init(
                forPreview: true,
                productsIsLoading: false,
                productsIsError: false
            )
        )
    }
}

#Preview("With Error") {
    NavigationStack {
        CategoriesScreen(
            viewModel: .init(
                forPreview: true,
                productsIsLoading: false,
                productsIsError: true
            )
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        CategoriesScreen(
            viewModel: .init(
                forPreview: true,
                productsIsLoading: true,
                productsIsError: false
            )
        )
    }
}

#endif
