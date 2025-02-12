//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Kingfisher
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
        VStack(spacing: 0) {
            if viewModel.cartManager.items.isEmpty {
                ContentUnavailableView(
                    "Your PlaceOrder is Empty.",
                    systemImage: "shippingbox",
                    description: Text("Add some products to continue.")
                )
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "map")
                            Text("Address")
                        }

                        TextField(
                            "Enter your address here...",
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
        .navigationTitle("Checkout")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            VStack {
                Divider()

                HStack {
                    Text("Total")

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

                        Text("Placing Order...")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Place Order")
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

                NavController.shared.popBackStack()
            }
        }
        .alert(
            "Order placed successfully!",
            isPresented: $showSuccessAlert
        ) {
            Button {
                showSuccessAlert.toggle()
            } label: {
                Text("Ok")
            }
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
