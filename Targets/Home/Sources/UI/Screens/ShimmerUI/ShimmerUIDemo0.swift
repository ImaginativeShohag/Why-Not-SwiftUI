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
                
                SubHeader("VContainer()")
                
                ShimmerUI.VContainer {
                    Image(systemName: "star")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("Lorem Ipsum")
                }
                
                SubHeader("HContainer()")
                
                ShimmerUI.HContainer {
                    Image(systemName: "star")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("Lorem Ipsum")
                }
                
                Divider()
                
                Header("Blocks")
                
                SubHeader("TextBlock()")
                
                ShimmerUI.TextBlock(size: 20)
                
                Divider()
                
                SubHeader("SquireBlock()")
                
                ShimmerUI.SquireBlock(size: 48)
                
                Divider()
                
                SubHeader("RectangleBlock()")
                
                ShimmerUI.RectangleBlock(ratio: 1.77)
                
                ShimmerUI.RectangleBlock(width: 64, height: 96)
                
                Divider()
                
                SubHeader("FilledCircleBlock()")
                
                ShimmerUI.FilledCircleBlock(size: 48)
                
                Divider()
                
                SubHeader("OutlineCircleBlock()")
                
                ShimmerUI.OutlineCircleBlock(size: 64)
                
                Divider()
                
                SubHeader("VCardBlock()")
                
                ShimmerUI.VCardBlock {
                    ShimmerUI.SquireBlock(size: 48)
                    ShimmerUI.SquireBlock(size: 48)
                    ShimmerUI.SquireBlock(size: 48)
                }
                
                Divider()
                
                SubHeader("HCardBlock()")
                
                ShimmerUI.HCardBlock {
                    ShimmerUI.SquireBlock(size: 48)
                    ShimmerUI.SquireBlock(size: 48)
                    ShimmerUI.SquireBlock(size: 48)
                }
                
                Divider()
                
                SubHeader("VStackBlock()")
                
                ShimmerUI.VStackBlock {
                    ShimmerUI.SquireBlock(size: 48)
                    ShimmerUI.SquireBlock(size: 48)
                    ShimmerUI.SquireBlock(size: 48)
                }
                
                Divider()
                
                SubHeader("HStackBlock()")
                
                ShimmerUI.HStackBlock {
                    ShimmerUI.SquireBlock(size: 48)
                    ShimmerUI.SquireBlock(size: 48)
                    ShimmerUI.SquireBlock(size: 48)
                }
                
                Divider()
                
                SubHeader("VGridBlock()")
                
                ShimmerUI.VGridBlock {
                    ShimmerUI.ForEachBlock(count: 3) {
                        ShimmerUI.RectangleBlock(height: 48)
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
