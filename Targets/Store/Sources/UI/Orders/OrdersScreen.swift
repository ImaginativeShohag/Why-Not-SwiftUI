//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Kingfisher
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class Orders: BaseDestination {
        override public func getScreen() -> any View {
            OrdersScreen()
        }
    }
}

// MARK: - UI

struct OrdersScreen: View {
    @State private var viewModel: OrdersViewModel

    init(viewModel: OrdersViewModel = OrdersViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                ProgressView()

            case .error(let message):
                Text(message)

            case .data(let orders):
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(orders) { order in
                            OrderItem(
                                order: order
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitle("Orders")
        .refreshable {
            await viewModel.loadOrders(forced: true)
        }
        .task {
            await viewModel.loadOrders()
        }
    }
}

private struct OrderItem: View {
    let order: UIStore.Order

    @State var isExpended = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("#\(order.id)")

                Spacer()

                Text("\(order.orderedAt.toString(dateFormat: "dd MMM yyyy") ?? "-")")
            }
            .frame(maxWidth: .infinity)

            Button {
                withAnimation {
                    isExpended.toggle()
                }
            } label: {
                HStack {
                    Text("Total ^[\(order.products.count) product](inflect: true)")

                    Spacer()

                    Image(systemName: isExpended ? "chevron.compact.down" : "chevron.compact.up")
                }
            }
            .buttonStyle(.bordered)

            if isExpended {
                Divider()

                ForEach(order.products) { product in
                    HStack {
                        GeometryReader { geo in
                            KFImage(URL(string: product.image))
                                .placeholder {
                                    Image(systemName: "photo")
                                        .foregroundStyle(Color(.label).opacity(0.5))
                                }
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .frame(width: geo.size.width, height: geo.size.height)
                        }
                        .frame(width: 48, height: 48)
                        .background(Color.white)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.systemGroupedBackground, lineWidth: 2)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(product.title)
                                .font(.system(.subheadline, weight: .semibold))
                                .lineLimit(1)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )

                            HStack {
                                Text("$\(String(format: "%.2f", product.price)) × \(product.quantity)")

                                Spacer()

                                Text("$\(String(format: "%.2f", Double(product.price) * Double(product.quantity)))")
                            }
                            .font(.system(.callout, weight: .bold))
                            .lineLimit(1)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.tertiarySystemGroupedBackground)
        }
        .padding(.horizontal)
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        OrdersScreen(
            viewModel: OrdersViewModel(
                forPreview: true,
                productsIsLoading: false,
                productsIsError: false
            )
        )
    }
}

#endif
