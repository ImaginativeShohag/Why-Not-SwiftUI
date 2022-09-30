//
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import SwiftUI

struct RingChart: View {
    let rings: [RingChartRing]
    let lineWidth: CGFloat = 10
    let lineGap: CGFloat = 6

    var body: some View {
        ZStack {
            ForEach(rings.indices, id: \.self) { index in
                RingChartRingView(
                    ring: rings[index],
                    index: index,
                    lineWidth: lineWidth,
                    lineGap: lineGap
                )
            }
        }
    }
}

private struct RingChartRingView: View {
    var ring: RingChartRing
    var index: Int
    let lineWidth: CGFloat
    let lineGap: CGFloat

    @State private var showRing: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.3), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: showRing ? ring.progress / 100 : 0)
                .stroke(ring.color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(.init(degrees: -90))
        }
        .padding(CGFloat(index) * (lineWidth + lineGap))
        .onAppear {
            // show after initial animation finished
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(
                    .interactiveSpring(response: 1, dampingFraction: 1, blendDuration: 1)
                        .delay(Double(index) * 0.1)
                ) {
                    showRing = true
                }
            }
        }
    }
}

struct RingChart_Previews: PreviewProvider {
    static var previews: some View {
        RingChart(rings: [
            RingChartRing(progress: 72, color: Color.green),
            RingChartRing(progress: 36, color: Color.red),
            RingChartRing(progress: 91, color: Color.purple),
        ])
        .frame(width: 150, height: 150)
    }
}
