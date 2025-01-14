//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CommonUI
import SwiftUI

struct ShimmerUIDemo2: View {
    var body: some View {
        ScrollView {
            ShimmerUI.VContainer(alignment: .leading) {
                ShimmerUI.VGridBlock {
                    ShimmerUI.ForEachBlock(count: Int.random(in: 4 ... 5)) {
                        ShimmerUI.HCardBlock {
                            ShimmerUI.FilledSquareBlock(size: 25)
                                
                            ShimmerUI.TextBlock(size: Int.random(in: 25 ... 32))
                                
                            Spacer()
                                
                            ShimmerUI.FilledCircleBlock(size: 15)
                        }
                    }
                }
                
                ShimmerUI.TextBlock(size: 15)
                
                ShimmerUI.VGridBlock {
                    ShimmerUI.ForEachBlock(count: Int.random(in: 3 ... 5)) {
                        ShimmerUI.HCardBlock {
                            ShimmerUI.FilledSquareBlock(size: 25)
                                
                            ShimmerUI.TextBlock(size: Int.random(in: 25 ... 32))
                                
                            Spacer()
                                
                            ShimmerUI.FilledCircleBlock(size: 15)
                        }
                    }
                }
                
                ShimmerUI.TextBlock(size: 15, font: .title3)
                
                ShimmerUI.TextBlock(size: 15, font: .subheadline)
                
                ShimmerUI.VGridBlock {
                    ShimmerUI.ForEachBlock(count: Int.random(in: 3 ... 5)) {
                        ShimmerUI.HCardBlock {
                            ShimmerUI.FilledSquareBlock(size: 25)
                                
                            ShimmerUI.TextBlock(size: Int.random(in: 25 ... 32))
                                
                            Spacer()
                                
                            ShimmerUI.FilledSquareBlock(size: 15)
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
    ShimmerUIDemo2()
}
