//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CommonUI
import SwiftUI

struct ShimmerUIDemo0: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Header("Containers")
                
                Text("All items inside the container will be shimmering.")
                    .multilineTextAlignment(.center)
                
                Divider()
                
                SubHeader("VContainer()")
                
                ShimmerUI.VContainer {
                    Image(systemName: "star")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("Lorem Ipsum")
                }
                
                Divider()
                
                SubHeader("HContainer()")
                
                ShimmerUI.HContainer {
                    Image(systemName: "star")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("Lorem Ipsum")
                }
                
                Divider()
                
                Header("Blocks")
                
                Text("Use following ready-to-use blocks inside the above containers to add shimmer effect.")
                    .multilineTextAlignment(.center)
                
                Divider()
                
                SubHeader("TextBlock()")
                
                ShimmerUI.TextBlock(size: 20)
                
                Divider()
                
                SubHeader("FilledSquareBlock()")
                
                ShimmerUI.FilledSquareBlock(size: 48)
                
                Divider()
                
                SubHeader("BorderedSquareBlock()")
                
                ShimmerUI.BorderedSquareBlock(size: 48)
                
                Divider()
                
                SubHeader("FilledRectangleBlock()")
                
                ShimmerUI.FilledRectangleBlock(ratio: 1.77)
                
                ShimmerUI.FilledRectangleBlock(width: 64, height: 96)
                
                Divider()
                
                SubHeader("BorderedRectangleBlock()")
                
                ShimmerUI.BorderedRectangleBlock(ratio: 1.77)
                
                ShimmerUI.BorderedRectangleBlock(width: 64, height: 96)
                
                Divider()
                
                SubHeader("FilledCircleBlock()")
                
                ShimmerUI.FilledCircleBlock(size: 48)
                
                Divider()
                
                SubHeader("BorderedCircleBlock()")
                
                ShimmerUI.BorderedCircleBlock(size: 64)
                
                Divider()
                
                SubHeader("VCardBlock()")
                
                ShimmerUI.VCardBlock {
                    ShimmerUI.FilledSquareBlock(size: 48)
                    ShimmerUI.FilledSquareBlock(size: 48)
                    ShimmerUI.FilledSquareBlock(size: 48)
                }
                
                Divider()
                
                SubHeader("HCardBlock()")
                
                ShimmerUI.HCardBlock {
                    ShimmerUI.FilledSquareBlock(size: 48)
                    ShimmerUI.FilledSquareBlock(size: 48)
                    ShimmerUI.FilledSquareBlock(size: 48)
                }
                
                Divider()
                
                SubHeader("VStackBlock()")
                
                ShimmerUI.VStackBlock {
                    ShimmerUI.FilledSquareBlock(size: 48)
                    ShimmerUI.FilledSquareBlock(size: 48)
                    ShimmerUI.FilledSquareBlock(size: 48)
                }
                
                Divider()
                
                SubHeader("HStackBlock()")
                
                ShimmerUI.HStackBlock {
                    ShimmerUI.FilledSquareBlock(size: 48)
                    ShimmerUI.FilledSquareBlock(size: 48)
                    ShimmerUI.FilledSquareBlock(size: 48)
                }
                
                Divider()
                
                SubHeader("VGridBlock()")
                
                ShimmerUI.VGridBlock {
                    ShimmerUI.ForEachBlock(count: 3) {
                        ShimmerUI.FilledRectangleBlock(height: 48)
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
    ShimmerUIDemo0()
}

// MARK: - Components

private struct Header: View {
    let label: String
    
    init(_ label: String) {
        self.label = label
    }
    
    var body: some View {
        Text(label)
            .font(.title)
            .fontWeight(.bold)
    }
}

private struct SubHeader: View {
    let label: String
    
    init(_ label: String) {
        self.label = label
    }
    
    var body: some View {
        Text(label)
            .font(.title3)
            .monospaced()
    }
}
