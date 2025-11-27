//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import LocalizeKit
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class Products: BaseDestination {
        let categoryId: String

        init(categoryId: String) {
            self.categoryId = categoryId
        }

        override public func getScreen() -> any View {
            ProductsScreen(
                viewModel: ProductsViewModel(categoryId: categoryId)
            )
        }
    }
}

// MARK: - UI

struct ProductsScreen: View {
    @State var viewModel: ProductsViewModel

    init(viewModel: ProductsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            switch viewModel.productsState {
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

                case .data(let products):
                    ScrollView {
                        LazyVGrid(
                            columns: Array(repeating: .init(spacing: 16), count: 2),
                            spacing: 16
                        ) {
                            ForEach(products) { product in
                                Button {
                                    NavController.shared.navigateTo(
                                        Destination.ProductDetails(productId: product.id)
                                    )
                                } label: {
                                    ProductView(
                                        title: product.title,
                                        price: product.price,
                                        image: product.image,
                                        rating: product.ratingRate,
                                        ratingCount: product.ratingCount,
                                        quantity: product.quantity,
                                        onPlusClick: {
                                            viewModel.increaseQuantity(for: product)
                                        },
                                        onMinusClick: {
                                            viewModel.decreaseQuantity(for: product)
                                        }
                                    )
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(
            Text.localized(
                "store_products_category_title",
                default: "Category: %@",
                comment: "Title showing the current category name",
                with: viewModel.categoryId.capitalized
            )
        )
        .refreshable {
            await viewModel.loadProducts(forced: true)
        }
        .task {
            await viewModel.loadProducts()
        }
        .onLanguageChange()
    }
}

#if DEBUG

#Preview("With Data") {
    NavigationStack {
        ProductsScreen(
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
        ProductsScreen(
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
        ProductsScreen(
            viewModel: .init(
                forPreview: true,
                productsIsLoading: true,
                productsIsError: false
            )
        )
    }
}

#endif
