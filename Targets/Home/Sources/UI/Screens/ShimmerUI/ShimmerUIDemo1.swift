//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI
import CommonUI

struct ShimmerUIDemo1: View {
    var body: some View {
        ScrollView {
            ShimmerUI.VContainer(alignment: .leading) {
                ShimmerUI.TextBlock(size: 25, font: .title3)
                            
                ShimmerUI.TextBlock(size: 20, font: .subheadline)
                        
                ShimmerUI.VCardBlock(alignment: .leading) {
                    ShimmerUI.HStackBlock {
                        ShimmerUI.TextBlock(size: 20, font: .subheadline)
                                
                        ShimmerUI.TextBlock(size: 15, font: .subheadline)
                                
                        Spacer()
                    }
                            
                    ShimmerUI.TextBlock(size: Int.random(in: 20 ... 30), line: 2)
                            
                    ShimmerUI.FilledRectangleBlock(ratio: 1.77)
                                    
                    ShimmerUI.ForEachBlock(count: Int.random(in: 2 ... 3)) {
                        ShimmerUI.HStackBlock(spacing: 12) {
                            ShimmerUI.FilledSquareBlock(size: 25)
                                    
                            ShimmerUI.TextBlock(size: Int.random(in: 25 ... 35))
                                    
                            Spacer()
                        }
                    }
                            
                    ShimmerUI.TextBlock(size: 15)
                            
                    ShimmerUI.FilledRectangleBlock(width: nil, height: 80)
                            
                    ShimmerUI.TextBlock(size: 15)
                            
                    ShimmerUI.HStackBlock {
                        ShimmerUI.FilledRectangleBlock(ratio: 1.77)
                            .frame(width: 120)
                                
                        Spacer()
                    }
                }
                        
                Spacer()
            }
            .frame(maxWidth: 768)
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .background(Color.systemGroupedBackground)
    }
}

#Preview {
    ShimmerUIDemo1()
}
