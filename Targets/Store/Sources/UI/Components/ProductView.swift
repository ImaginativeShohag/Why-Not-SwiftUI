//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Kingfisher
import SwiftUI
import Core

struct ProductView: View {
    let title: String
    let price: Double
    let image: String
    let rating: Double
    let ratingCount: Int
    let quantity: Int
    let onPlusClick: () -> Void
    let onMinusClick: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                KFImage(URL(string: image))
                    .placeholder {
                        Image(systemName: "photo")
                            .foregroundStyle(Color(.label).opacity(0.5))
                    }
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .frame(width: geo.size.width, height: geo.size.height)
            }
            .aspectRatio(1, contentMode: .fit)
            .background(Color.white)
            .clipped()
            .overlay(
                LinearGradient(
                    gradient: Gradient(
                        colors: [Color.clear, Color.black.opacity(0.15)]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 16),
                alignment: .bottom
            )
            .clipShape(
                RoundedCorner(
                    radius: 16,
                    corners: [.bottomLeft, .bottomRight]
                )
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .lineLimit(1)
                    .font(.system(.subheadline, weight: .semibold))

                Text("$\(String(format: "%.2f", price))")
                    .font(.system(.callout, weight: .bold))
                    .foregroundStyle(Color.red)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.yellow)

                    Text("\(String(format: "%.1f", rating))")

                    Text("(\(ratingCount))")
                }
                .font(.footnote)
                .foregroundStyle(Color.gray)
            }
            .padding(8)

            Divider()

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
            .padding(8)
        }
        .background(Color.tertiarySystemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview("ProductView") {
    ScrollView {
        LazyVGrid(
            columns: Array(repeating: .init(spacing: 8), count: 2),
            spacing: 8
        ) {
            ForEach(1 ..< 10) { index in
                ProductView(
                    title: "Lorem Ipsum",
                    price: 123.45,
                    image: "https://picsum.photos/seed/\(index)/200/300",
                    rating: 3.5,
                    ratingCount: 999,
                    quantity: 999,
                    onPlusClick: {},
                    onMinusClick: {}
                )
            }
        }
        .padding()
    }
    .background(Color.systemGroupedBackground)
}
