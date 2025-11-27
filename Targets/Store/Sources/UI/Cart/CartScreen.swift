//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Kingfisher
import LocalizeKit
import NavigationKit
import SwiftUI

struct CartScreen: View {
    @State var viewModel: CartViewModel
    @State var showSuccessAlert: Bool = false

    init(viewModel: CartViewModel = CartViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationViewStack {
            VStack(spacing: 0) {
                if viewModel.cartManager.items.isEmpty {
                    ContentUnavailableView {
                        Text.localized(
                            "store_cart_empty_title",
                            default: "Your Cart is Empty.",
                            comment: "Title shown when cart has no items"
                        )
                    } description: {
                        Text.localized(
                            "store_cart_empty_description",
                            default: "Add some products to continue.",
                            comment: "Description for empty cart state"
                        )
                    } actions: {
                        EmptyView()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(Array(viewModel.cartManager.items)) { product in
                                CartItemView(
                                    title: product.title,
                                    price: product.price,
                                    image: product.image,
                                    rating: product.ratingRate,
                                    ratingCount: product.ratingCount,
                                    quantity: product.quantity,
                                    onPlusClick: { viewModel.increaseQuantity(for: product) },
                                    onMinusClick: { viewModel.decreaseQuantity(for: product) }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.systemGroupedBackground)
            .navigationTitle("store_cart_title".localize(default: "Cart", comment: "Cart screen title"))
            .safeAreaInset(edge: .bottom) {
                VStack {
                    Divider()

                    HStack {
                        Text.localized(
                            "store_cart_total",
                            default: "Total",
                            comment: "Label for total price in cart"
                        )

                        Spacer()

                        Text("$\(String(format: "%.2f", viewModel.totalPrice()))")
                    }
                    .font(.title3.bold())
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                    Button {
                        NavController.shared
                            .navigateTo(Destination.PlaceOrder())
                    } label: {
                        Text.localized(
                            "store_cart_checkout",
                            default: "Check Out",
                            comment: "Button to proceed to checkout"
                        )
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.cartManager.items.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(.thinMaterial)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("store_cart_menu_orders".localize(default: "Orders", comment: "Menu item to view orders")) {
                            NavController.shared.navigateTo(Destination.Orders())
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
            .onLanguageChange()
        }
    }
}

#if DEBUG

#Preview("With Data") {
    CartScreen(
        viewModel: .init(
            forPreview: true,
            productIsEmpty: false
        )
    )
}

#Preview("With Empty Data") {
    CartScreen(
        viewModel: .init(
            forPreview: true,
            productIsEmpty: true
        )
    )
}

#endif

private struct CartItemView: View {
    let title: String
    let price: Double
    let image: String
    let rating: Double
    let ratingCount: Int
    let quantity: Int
    let onPlusClick: () -> Void
    let onMinusClick: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    GeometryReader { geo in
                        KFImage(URL(string: image))
                            .placeholder {
                                Image(systemName: "photo")
                                    .foregroundStyle(Color(.label).opacity(0.5))
                            }
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                    .frame(width: 60, height: 60)
                    .background(Color.white)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.systemGroupedBackground, lineWidth: 2)
                    }

                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.system(.subheadline, weight: .semibold))
                            .lineLimit(1)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )

                        Text("$\(String(format: "%.2f", price))")
                            .font(.system(.callout, weight: .bold))
                            .lineLimit(1)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                    }
                }

                Divider()
                    .padding(.vertical, 4)

                HStack {
                    HStack {
                        Button {
                            onPlusClick()
                        } label: {
                            Image(systemName: "plus.square")
                        }

                        Text("\(quantity)")
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)

                        Button {
                            onMinusClick()
                        } label: {
                            Image(systemName: "minus.square")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(width: 150)

                    Spacer()

                    Text("$\(String(format: "%.2f", price * Double(quantity)))")
                        .font(.system(.body, weight: .bold))
                        .foregroundStyle(Color.red)
                        .lineLimit(1)
                }
            }
            .padding(8)
        }
        .background(Color.tertiarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
