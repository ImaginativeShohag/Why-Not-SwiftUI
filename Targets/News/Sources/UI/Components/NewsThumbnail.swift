//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Kingfisher
import SwiftUI

@MainActor
struct NewsThumbnail: View {
    let url: String

    var body: some View {
        GeometryReader { geo in
            KFImage(URL(string: url))
                .placeholder {
                    Image(systemName: "photo")
                        .foregroundStyle(Color(.label).opacity(0.5))
                }
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1.78, contentMode: .fill)
        .background(Color(.secondarySystemBackground))
        .clipped()
    }
}
