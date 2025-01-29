//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Kingfisher
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class ProductDetails: BaseDestination {
        let productId: Int

        init(productId: Int) {
            self.productId = productId
        }

        override public func getScreen() -> any View {
            ProductDetailsScreen(
                viewModel: ProductDetailsViewModel(
                    productId: productId
                )
            )
        }
    }
}

// MARK: - UI

struct ProductDetailsScreen: View {
    @State private var viewModel: ProductDetailsViewModel

    init(viewModel: ProductDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            switch viewModel.productState {
            case .loading:
                ProgressView()

            case .error(let message):
                Text(message)

            case .data(let product):
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack(spacing: 0) {
                            GeometryReader { proxy in
                                KFImage(URL(string: product.image))
                                    .placeholder {
                                        Image(systemName: "photo")
                                            .foregroundStyle(Color(.label).opacity(0.5))
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .padding()
                                    .frame(
                                        width: proxy.size.width,
                                        height: proxy.size.height
                                    )
                            }
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .background(Color.white)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [Color.clear, Color.black.opacity(0.15)]
                                    ),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .frame(height: 32),
                                alignment: .bottom
                            )
                            .clipShape(
                                RoundedCorner(
                                    radius: 32,
                                    corners: [.bottomLeft, .bottomRight]
                                )
                            )

                            VStack(alignment: .leading, spacing: 8) {
                                Text(product.title)
                                    .frame(
                                        maxWidth: .infinity,
                                        alignment: .leading
                                    )
                                    .lineLimit(1)
                                    .font(.system(.title3, weight: .semibold))

                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(Color.yellow)

                                    Text("\(String(format: "%.1f", product.rating.rate))")

                                    Text("(\(product.rating.count))")
                                }
                                .font(.footnote)
                                .foregroundStyle(Color.gray)

                                Text(product.description)
                                    .font(.body)
                            }
                            .padding()
                        }
                    }

                    // MARK: Bottom Section
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let product = viewModel.productState.getData() {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.system(.body, weight: .bold))
                            .foregroundStyle(Color.red)

                        Spacer()

                        HStack {
                            Button {
                                //
                            } label: {
                                Image(systemName: "plus.square")
                            }

                            Text("999")
                                .lineLimit(1)
                                .frame(maxWidth: .infinity)

                            Button {
                                //
                            } label: {
                                Image(systemName: "minus.square")
                            }
                        }
                        .frame(maxWidth: 150)
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .refreshable {
            await viewModel.loadProduct(forced: true)
        }
        .task {
            await viewModel.loadProduct()
        }
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        ProductDetailsScreen(
            viewModel: ProductDetailsViewModel(
                forPreview: true,
                productsIsLoading: false,
                productsIsError: false
            )
        )
    }
}

#endif
