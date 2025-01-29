//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Kingfisher
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class StoreHome: BaseDestination {
        override public func getScreen() -> any View {
            HomeScreen()
        }
    }
}

// MARK: - UI

struct HomeScreen: View {
    @State var viewModel: HomeViewModel

    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CarouselSection()

                CategorySection(
                    categoriesState: viewModel.categoriesState,
                    onCategoryClick: { category in
                        NavController.shared.navigateTo(
                            Destination.Products(categoryId: category)
                        )
                    }
                )

                ProductListSection(
                    productsState: viewModel.productsState,
                    onProductClick: { product in
                        NavController.shared.navigateTo(
                            Destination.ProductDetails(productId: product.id)
                        )
                    }
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGroupedBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Store Overflow")
        .refreshable {
            await viewModel.loadCategories(forced: true)
            await viewModel.loadProducts(forced: true)
        }
        .task {
            await viewModel.loadCategories()
            await viewModel.loadProducts()
        }
    }
}

#if DEBUG

#Preview("With Data") {
    NavigationStack {
        HomeScreen(
            viewModel: HomeViewModel(
                forPreview: true,
                productsIsLoading: false,
                productsIsError: false,
                categoriesIsLoading: false,
                categoriesIsError: false
            )
        )
    }
}

#Preview("With Error") {
    NavigationStack {
        HomeScreen(
            viewModel: HomeViewModel(
                forPreview: true,
                productsIsLoading: false,
                productsIsError: true,
                categoriesIsLoading: false,
                categoriesIsError: true
            )
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        HomeScreen(
            viewModel: HomeViewModel(
                forPreview: true,
                productsIsLoading: true,
                productsIsError: false,
                categoriesIsLoading: true,
                categoriesIsError: false
            )
        )
    }
}

#endif

private struct CarouselSection: View {
    private var colorsForCarousel: [Color] = [.red, .green, .yellow, .blue, .orange, .accentColor, .cyan, .brown, .indigo]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 16) {
                ForEach(0 ..< colorsForCarousel.count, id: \.self) { index in
                    let color = colorsForCarousel[index]

                    Button {
                        //
                    } label: {
                        GeometryReader { geo in
                            KFImage(URL(string: "https://picsum.photos/seed/\(index)/300/300"))
                                .placeholder {
                                    Image(systemName: "photo")
                                        .foregroundStyle(Color(.label).opacity(0.5))
                                }
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                        .background(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(color, lineWidth: 4)
                        }
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 4, x: 1, y: 1)
                        .frame(width: UIScreen.main.bounds.width - 64, height: 150)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .scaleEffect(y: phase.isIdentity ? 1 : 0.9)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollTargetLayout()
        }
        .contentMargins(16, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
    }
}

private struct CategorySection: View {
    var categoriesState: UIState<[Category]>
    let onCategoryClick: (Category) -> Void

    var body: some View {
        switch categoriesState {
            case .loading:
                ProgressView()

            case .error(let message):
                Text(message)

            case .data(let categories):
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(categories, id: \.self) { category in
                            Button {
                                onCategoryClick(category)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "shippingbox")

                                    Text(category)
                                }
                                .font(.system(.subheadline, weight: .semibold))
                                .padding(8)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.25))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
        }
    }
}

private struct ProductListSection: View {
    var productsState: UIState<[Product]>
    let onProductClick: (Product) -> Void

    var body: some View {
        switch productsState {
            case .loading:
                HStack {
                    ProgressView()
                }

            case .error(let message):
                Text(message)

            case .data(let products):
                LazyVGrid(
                    columns: Array(repeating: .init(spacing: 8), count: 2),
                    spacing: 8
                ) {
                    ForEach(products) { product in
                        Button {
                            onProductClick(product)
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
}
