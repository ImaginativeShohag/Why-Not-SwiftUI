//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Kingfisher
import LocalizeKit
import NavigationKit
import SwiftUI

// MARK: - Destination

extension Destination {
    final class PlaceOrder: BaseDestination {
        override public func getScreen() -> any View {
            PlaceOrderScreen()
        }
    }
}

// MARK: - UI

struct PlaceOrderScreen: View {
    @State var viewModel: PlaceOrderViewModel
    @State var showSuccessAlert: Bool = false

    init(viewModel: PlaceOrderViewModel = PlaceOrderViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 0) {
            if viewModel.cartManager.items.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "map")
                            Text.localized(
                                "store_checkout_shipping_address",
                                default: "Shipping Address",
                                comment: "Label for shipping address section"
                            )
                        }

                        TextField(
                            "store_checkout_name_placeholder".localize(default: "Your name...", comment: "Name TextField placeholder"),
                            text: $viewModel.nameText
                        )
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        }

                        TextField(
                            "store_checkout_phone_placeholder".localize(default: "Phone number...", comment: "Phone TextField placeholder"),
                            text: $viewModel.phoneNumberText
                        )
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        }

                        TextField(
                            "store_checkout_address_placeholder".localize(default: "Address...", comment: "Address TextField placeholder"),
                            text: $viewModel.addressText,
                            axis: .vertical
                        )
                        .lineLimit(4, reservesSpace: true)
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        }

                        HStack {
                            Image(systemName: "cube.box")
                            Text("\(viewModel.cartManager.items.count) ^[Products](\(viewModel.cartManager.items.count))")
                        }

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
                    .disabled(viewModel.orderSubmitState?.isLoading == true)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGroupedBackground)
        .navigationTitle("store_checkout_title".localize(default: "Checkout", comment: "Checkout screen title"))
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack {
                Divider()

                HStack {
                    Text.localized(
                        "store_checkout_total",
                        default: "Total",
                        comment: "Label for total price in checkout"
                    )

                    Spacer()

                    Text("$\(String(format: "%.2f", viewModel.totalPrice()))")
                }
                .font(.title3.bold())
                .padding(.horizontal)
                .padding(.vertical, 8)

                Button {
                    Task {
                        await viewModel.submitOrder()
                    }
                } label: {
                    if viewModel.orderSubmitState == .loading {
                        ProgressView()

                        Text.localized(
                            "store_checkout_placing_order",
                            default: "Placing Order...",
                            comment: "Button text while placing order"
                        )
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text.localized(
                            "store_checkout_place_order",
                            default: "Place Order",
                            comment: "Button to place order"
                        )
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    viewModel.cartManager.items.isEmpty
                        || viewModel.addressText.isEmpty
                        || viewModel.orderSubmitState?.isLoading == true
                )
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(.thinMaterial)
        }
        .onChange(of: viewModel.orderSubmitState) { _, newState in
            if let newState, let isSuccess = newState.getData(), isSuccess {
                showSuccessAlert = true
            }
        }
        .alert(
            "store_checkout_success_title".localize(default: "Order placed successfully!", comment: "Success alert title"),
            isPresented: $showSuccessAlert
        ) {
            Button {
                NavController.shared.popBackStack()
            } label: {
                Text.localized(
                    "store_ok",
                    default: "Ok",
                    comment: "OK button text"
                )
            }
        }
        .onLanguageChange()
    }

    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableView {
            Text.localized(
                "store_checkout_completed_title",
                default: "Checkout is completed.",
                comment: "Title shown when checkout is complete"
            )
        } description: {
            Text.localized(
                "store_checkout_completed_description",
                default: "Add some products to continue again.",
                comment: "Description for completed checkout"
            )
        } actions: {
            EmptyView()
        }
    }
}

#if DEBUG

#Preview("With Data") {
    NavigationStack {
        PlaceOrderScreen(
            viewModel: .init(
                forPreview: true,
                productIsEmpty: false,
                productsIsLoading: false,
                productsIsError: false
            )
        )
    }
}

#Preview("With Empty Data") {
    NavigationStack {
        PlaceOrderScreen(
            viewModel: .init(
                forPreview: true,
                productIsEmpty: true,
                productsIsLoading: false,
                productsIsError: false
            )
        )
    }
}

#Preview("With Error") {
    NavigationStack {
        PlaceOrderScreen(
            viewModel: .init(
                forPreview: true,
                productIsEmpty: false,
                productsIsLoading: false,
                productsIsError: true
            )
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        PlaceOrderScreen(
            viewModel: .init(
                forPreview: true,
                productIsEmpty: false,
                productsIsLoading: true,
                productsIsError: false
            )
        )
    }
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
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: geo.size.width, height: geo.size.height)
                    }
                    .frame(width: 48, height: 48)
                    .background(Color.white)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
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

                        HStack(spacing: 0) {
                            Text("$\(String(format: "%.2f", price)) × ")
                                .font(.system(.callout, weight: .bold))
                                .lineLimit(1)

                            Text("\(quantity)")
                                .font(.system(.callout, weight: .bold))
                                .foregroundStyle(Color.red)
                                .lineLimit(1)

                            Spacer()

                            Text("$\(String(format: "%.2f", price * Double(quantity)))")
                                .font(.system(.body, weight: .bold))
                                .foregroundStyle(Color.red)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(8)
        }
        .background(Color.tertiarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
