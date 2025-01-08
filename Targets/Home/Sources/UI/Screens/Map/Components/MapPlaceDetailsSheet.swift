//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct MapPlaceDetailsSheet: View {
    let item: MapPlace

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    AsyncImage(
                        url: URL(
                            string: "https://picsum.photos/seed/\(item.name)/300/300"
                        ),
                        content: { image in
                            image.resizable()
                                .scaledToFill()
                                .frame(
                                    width: proxy.size.width,
                                    height: proxy.size.height
                                )
                                .clipped()
                        },
                        placeholder: {
                            ProgressView()
                                .frame(
                                    width: proxy.size.width,
                                    height: proxy.size.height
                                )
                        }
                    )
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(3, contentMode: .fit)
                .background(Color.gray.opacity(0.5))

                VStack(spacing: 8) {
                    Text(item.name)
                        .font(.title)
                    Text("\(item.location.latitude), \(item.location.longitude)")
                        .font(.subheadline)
                    Text(item.description)
                }
                .padding()
            }
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ZStack {}
        .sheet(isPresented: .constant(true)) {
            MapPlaceDetailsSheet(item: MapPlace.places.first!)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium])
        }
}
