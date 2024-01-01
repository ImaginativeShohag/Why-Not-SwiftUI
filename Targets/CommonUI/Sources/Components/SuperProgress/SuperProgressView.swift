//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI
import Core

public struct SuperProgressView: View {
    let value: CGFloat
    let total: CGFloat
    let height: CGFloat

    @State private var showView = false

    private var percentage: CGFloat {
        guard value != 0, total != 0 else { return 0 }
        return value / total
    }

    public init(value: CGFloat, total: CGFloat, height: CGFloat = 10) {
        self.value = value
        self.total = total
        self.height = height
    }

    public var body: some View {
        GeometryReader { geometry in
            HStack {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: showView ? (geometry.size.width * percentage) : 0)
                    .cornerRadius(height / 2, corners: [.topRight, .bottomRight])
            }
        }
        .frame(height: height)
        .background(Color(.systemGray5))
        .onAppear {
            // show after initial animation finished
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(
                    .interpolatingSpring(stiffness: 200, damping: 10)
                ) {
                    showView = true
                }
            }
        }
    }
}

struct SuperProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            VStack {
                ProgressView(value: 0, total: 1.0)
                SuperProgressView(value: 0, total: 1.0)
            }

            VStack {
                ProgressView(value: 0.25, total: 1.0)
                SuperProgressView(value: 0.25, total: 1.0)
            }

            VStack {
                ProgressView(value: 0.5, total: 1.0)
                    .accentColor(Color(.systemRed))
                SuperProgressView(value: 0.5, total: 1.0)
                    .accentColor(Color(.systemRed))
            }

            VStack {
                ProgressView(value: 0.75, total: 1.0)
                SuperProgressView(value: 0.75, total: 1.0)
            }

            VStack {
                ProgressView(value: 100, total: 100)
                SuperProgressView(value: 100, total: 100)
            }

            SuperProgressView(value: 50, total: 100, height: 16)
                .cornerRadius(8)
                .padding(.horizontal)
        }
        .accentColor(Color(.systemMint))
    }
}
