//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Kingfisher
import NavigationKit
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

struct HomeScreen: View {
    @State var viewModel: HomeViewModel

    @State private var scrollOffset: CGFloat = 0
    @State private var showProfile = false

    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationViewStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if let user = viewModel.user {
                            HStack {
                                Text("Welcome, **\(user.name.getFullName())**!")
                                    .font(.title)
                                    .lineLimit(1)

                                Spacer()

                                Button {
                                    showProfile.toggle()
                                } label: {
                                    ProfileView()
                                }
                            }
                            .padding()
                        }

                        CarouselSection()

                        CategorySection(
                            categoriesState: viewModel.categoriesState,
                            onCategoryClick: { category in
                                NavController.shared.navigateTo(
                                    Destination.Products(categoryId: category)
                                )
                            },
                            onRetryClick: {
                                Task {
                                    await viewModel.loadCategories(forced: true)
                                }
                            }
                        )

                        ProductListSection(
                            productsState: viewModel.productsState,
                            onProductClick: { product in
                                NavController.shared.navigateTo(
                                    Destination.ProductDetails(productId: product.id)
                                )
                            },
                            onProductIncreaseClick: { product in
                                viewModel.increaseQuantity(for: product)
                            },
                            onProductDecreaseClick: { product in
                                viewModel.decreaseQuantity(for: product)
                            },
                            onRetryClick: {
                                Task {
                                    await viewModel.loadProducts(forced: true)
                                }
                            }
                        )
                    }
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .onChange(
                                    of: proxy.frame(
                                        in: .named("ScrollView")
                                    ).minY
                                ) { _, newScrollOffset in
                                    scrollOffset = max(0, min(1, -newScrollOffset / 16))
                                }
                        }
                    )
                }
                .coordinateSpace(name: "ScrollView")

                // Blurred status bar overlay
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: statusBarHeight())
                    .opacity(scrollOffset)
                    .ignoresSafeArea()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.systemGroupedBackground)
            .refreshable {
                await viewModel.loadCategories(forced: true)
                await viewModel.loadProducts(forced: true)
            }
            .task {
                async let categories: () = viewModel.loadCategories()
                async let products: () = viewModel.loadProducts()

                let _ = await (categories, products)
            }
            .sheet(isPresented: $showProfile) {
                ProfileSheet()
            }
        }
    }

    // Function to get status bar height dynamically
    private func statusBarHeight() -> CGFloat {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
}

struct ProfileView: View {
    var body: some View {
        KFImage(URL(string: "https://picsum.photos/id/42/200/200"))
            .placeholder {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .foregroundStyle(Color(.label).opacity(0.5))
            }
            .resizable()
            .scaledToFill()
            .frame(width: 32, height: 32)
            .clipShape(Circle())
            .clipped()
    }
}

#if DEBUG

#Preview("With Data") {
    NavigationStack {
        TabView {
            HomeScreen(
                viewModel: HomeViewModel(
                    forPreview: true,
                    productsIsLoading: false,
                    productsIsError: false,
                    categoriesIsLoading: false,
                    categoriesIsError: false
                )
            )
            .tabItem {
                Label("Home", systemImage: "text.rectangle.page.fill")
            }
        }
    }
}

#Preview("With Error") {
    NavigationStack {
        TabView {
            HomeScreen(
                viewModel: HomeViewModel(
                    forPreview: true,
                    productsIsLoading: false,
                    productsIsError: true,
                    categoriesIsLoading: false,
                    categoriesIsError: true
                )
            )
            .tabItem {
                Label("Home", systemImage: "text.rectangle.page.fill")
            }
        }
    }
}

#Preview("Loading") {
    NavigationStack {
        TabView {
            HomeScreen(
                viewModel: HomeViewModel(
                    forPreview: true,
                    productsIsLoading: true,
                    productsIsError: false,
                    categoriesIsLoading: true,
                    categoriesIsError: false
                )
            )
            .tabItem {
                Label("Home", systemImage: "text.rectangle.page.fill")
            }
        }
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
    let categoriesState: UIState<[Category]>
    let onCategoryClick: (Category) -> Void
    let onRetryClick: () -> Void

    var body: some View {
        switch categoriesState {
            case .loading:
                ZStack {
                    ProgressView()
                        .padding()
                }
                .frame(maxWidth: .infinity)

            case .error(let message):
                ErrorView(message: message, onRetryClick: onRetryClick)

            case .data(let categories):
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(categories, id: \.self) { category in
                            Button {
                                onCategoryClick(category)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "shippingbox")

                                    Text(category.capitalized)
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
    let productsState: UIState<[UIStore.Product]>
    let onProductClick: (UIStore.Product) -> Void
    let onProductIncreaseClick: (UIStore.Product) -> Void
    let onProductDecreaseClick: (UIStore.Product) -> Void
    let onRetryClick: () -> Void

    var body: some View {
        switch productsState {
            case .loading:
                ZStack {
                    ProgressView()
                        .padding()
                }
                .frame(maxWidth: .infinity)

            case .error(let message):
                ErrorView(message: message, onRetryClick: onRetryClick)

            case .data(let products):
                LazyVGrid(
                    columns: Array(repeating: .init(spacing: 16), count: 2),
                    spacing: 16
                ) {
                    ForEach(products) { product in
                        Button {
                            onProductClick(product)
                        } label: {
                            ProductView(
                                title: product.title,
                                price: product.price,
                                image: product.image,
                                rating: product.ratingRate,
                                ratingCount: product.ratingCount,
                                quantity: product.quantity,
                                onPlusClick: {
                                    onProductIncreaseClick(product)
                                },
                                onMinusClick: {
                                    onProductDecreaseClick(product)
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
        }
    }
}
