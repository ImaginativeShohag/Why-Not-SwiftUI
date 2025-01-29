//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

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
        ScrollView {
            switch viewModel.productsState {
                case .loading:
                    ProgressView()

                case .error(let message):
                    Text(message)

                case .data(let products):
                    LazyVGrid(
                        columns: Array(repeating: .init(spacing: 8), count: 2),
                        spacing: 8
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
                                    rating: product.rating.rate,
                                    ratingCount: product.rating.count,
                                    quantity: 999,
                                    onPlusClick: {},
                                    onMinusClick: {}
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGroupedBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Category: \(viewModel.categoryId)")
        .refreshable {
            await viewModel.loadProducts(forced: true)
        }
        .task {
            await viewModel.loadProducts()
        }
    }
}

#Preview {
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
