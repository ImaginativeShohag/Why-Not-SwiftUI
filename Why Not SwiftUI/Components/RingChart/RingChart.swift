//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct RingChart: View {
    let rings: [RingChartRing]
    let ringWidth: CGFloat
    let ringGap: CGFloat

    init(rings: [RingChartRing], ringWidth: CGFloat = 10, ringGap: CGFloat = 6) {
        self.rings = rings
        self.ringWidth = ringWidth
        self.ringGap = ringGap
    }

    var body: some View {
        ZStack {
            ForEach(rings.indices, id: \.self) { index in
                RingChartRingView(
                    ring: rings[index],
                    index: index,
                    ringWidth: ringWidth,
                    ringGap: ringGap
                )
            }
        }
    }
}

private struct RingChartRingView: View {
    var ring: RingChartRing
    var index: Int
    let ringWidth: CGFloat
    let ringGap: CGFloat

    @State private var showRing: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.3), lineWidth: ringWidth)

            Circle()
                .trim(from: 0, to: showRing ? ring.progress / 100 : 0)
                .stroke(
                    ring.color,
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.init(degrees: -90))
        }
        .padding(CGFloat(index) * (ringWidth + ringGap))
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
            RingChartRing(progress: 45, color: Color.blue),
            RingChartRing(progress: 85, color: Color.purple),
        ])
        .frame(width: 150, height: 150)
    }
}
