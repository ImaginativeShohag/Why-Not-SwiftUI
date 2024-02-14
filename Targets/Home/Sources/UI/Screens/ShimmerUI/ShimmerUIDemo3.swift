//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CommonUI
import SwiftUI

struct ShimmerUIDemo3: View {
    var body: some View {
        ScrollView {
            ShimmerUI.VContainer(alignment: .leading) {
                ShimmerUI.VGridBlock {
                    ShimmerUI.ForEachBlock(count: Int.random(in: 3 ... 5)) {
                        ShimmerUI.HCardBlock {
                            ShimmerUI.VStackBlock(alignment: .leading, spacing: 4) {
                                ShimmerUI.TextBlock(size: Int.random(in: 25 ... 32))

                                ShimmerUI.TextBlock(size: Int.random(in: 20 ... 25))

                                ShimmerUI.TextBlock(size: Int.random(in: 25 ... 32))
                            }

                            Spacer()

                            ShimmerUI.OutlineCircleBlock(size: 50)
                        }
                    }
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .background(Color.systemGroupedBackground)
    }
}

#Preview {
    ShimmerUIDemo3()
}
