//
//  Copyright © 2022 Apple Inc. All rights reserved.
//

import SwiftUI

struct FitnessRingCardView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Progress")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 20) {
                // progress ring
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
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        .background {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(.ultraThinMaterial)
//                .shadow(color: .gray.opacity(0.2), radius: 8, x: 0, y: 0)
        }
    }
}

struct FitnessRingCardView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessRingCardView()
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

//
//  Ring.swift
//  FitnessAppUIAnimation
//
//  Created by Softzino MBP 302 on 9/16/22.
//

import SwiftUI

// MARK: Progress ring

struct Ring: Identifiable {
    var id = UUID().uuidString
    var progress: CGFloat
    var value: String
    var keyIcon: String
    var keyColor: Color
    var isText: Bool = false
}

var rings: [Ring] = [
    Ring(progress: 72, value: "Steps", keyIcon: "figure.walk", keyColor: Color.green),
    Ring(progress: 36, value: "Calories", keyIcon: "flame.fill", keyColor: Color.red),
    Ring(progress: 91, value: "Sleep time", keyIcon: "powersleep", keyColor: Color.purple, isText: false),
//    Ring(progress: 91, value: "Sleep time", keyIcon: "😴", keyColor: Color("Purple"), isText: true)
]
