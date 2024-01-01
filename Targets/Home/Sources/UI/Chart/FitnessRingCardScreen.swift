//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

public struct FitnessRingCardScreen: View {
    
    public init() {}
    
    public var body: some View {
        HStack(spacing: 24) {
            ZStack {
                ForEach(rings.indices, id: \.self) { index in
                    AnimatedRingView(ring: rings[index], index: index)
                }
            }
            .frame(width: 130, height: 130)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(rings) { ring in
                    Label {
                        HStack(alignment: .bottom, spacing: 6) {
                            Text("\(Int(ring.progress))%")
                                .font(.title3.bold())
                            Text(ring.value)
                                .font(.caption)
                        }
                    } icon: {
                        Group {
                            if ring.isText {
                                Text(ring.keyIcon)
                                    .font(.title2)
                            } else {
                                Image(systemName: ring.keyIcon)
                                    .font(.title2)
                                    .foregroundColor(ring.keyColor)
                            }
                        }
                        .frame(width: 30)
                    }
                }
            }
            .padding(.leading, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        .background {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .padding()
        .navigationTitle("Ring Chart: Fitness")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FitnessRingCardView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessRingCardScreen()
    }
}

// MARK: Animate rings

struct AnimatedRingView: View {
    var ring: Ring
    var index: Int
    @State var showRing: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.3), lineWidth: 10)

            Circle()
                .trim(from: 0, to: showRing ? rings[index].progress / 100 : 0)
                .stroke(rings[index].keyColor, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .rotationEffect(.init(degrees: -90))
        }
        .padding(CGFloat(index) * 16)
        .onAppear {
            // show after initial animation finished
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.interactiveSpring(response: 1, dampingFraction: 1, blendDuration: 1).delay(Double(index) * 0.1)) {
                    showRing = true
                }
            }
        }
    }
}

// MARK: Model

struct Ring: Identifiable {
    var id = UUID().uuidString
    var progress: CGFloat
    var value: String
    var keyIcon: String
    var keyColor: Color
    var isText: Bool = false
}

var rings: [Ring] = [
    Ring(progress: 24, value: "Steps", keyIcon: "figure.walk", keyColor: Color.green),
    Ring(progress: 90, value: "Calories", keyIcon: "flame.fill", keyColor: Color.red),
    Ring(progress: 72, value: "Sleep time", keyIcon: "powersleep", keyColor: Color.purple, isText: false),
]
