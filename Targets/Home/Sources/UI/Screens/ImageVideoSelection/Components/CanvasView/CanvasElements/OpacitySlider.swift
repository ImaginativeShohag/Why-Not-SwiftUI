//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct OpacitySlider: View {
    @Binding var opacity: Double

    let sliderHeight: CGFloat = 32
    var horizontalPadding: CGFloat { sliderHeight / 2 }

    init(opacity: Binding<Double>) {
        self._opacity = opacity
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Checkerboard background
                Checkerboard()
                    .padding(.horizontal, -horizontalPadding)

                // Gradient overlay (white to black)
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0), .black]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(Capsule())
                .opacity(0.8)
                .padding(.horizontal, -horizontalPadding)

                // Slider Thumb
                Circle()
                    .strokeBorder(Color.white, lineWidth: 2)
                    .background(Circle().fill(Color.black.opacity(opacity)))
                    .background(Circle().fill(Color.white))
                    .frame(width: sliderHeight - 8, height: sliderHeight - 8)
                    .position(
                        x: CGFloat(opacity) * (geometry.size.width),
                        y: geometry.size.height / 2
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let limitedX = min(max(0, value.location.x), geometry.size.width)
                                opacity = Double(limitedX / geometry.size.width)

                                print("debug1: opacity: \(opacity)")
                                print("debug1: x: \(CGFloat(opacity) * (geometry.size.width))")
                            }
                    )
            }
            .frame(height: sliderHeight)
        }
        .frame(height: sliderHeight)
        .padding(.horizontal, horizontalPadding)
    }
}

// Checkerboard background pattern
private struct Checkerboard: View {
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) / 3
            let columns = Int(geometry.size.width / size)
            let rows = Int(geometry.size.height / size)

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<columns, id: \.self) { column in
                            Rectangle()
                                .fill((row + column).isMultiple(of: 2) ? Color.gray.opacity(0.3) : Color.white)
                                .frame(width: size, height: size)
                        }
                    }
                }
            }
        }
        .clipShape(Capsule())
    }
}

#Preview {
    @Previewable @State var opacity = 0.5

    VStack(spacing: 40) {
        OpacitySlider(opacity: .constant(0))
            .border(.red)

        OpacitySlider(opacity: .constant(1))
            .border(.red)

        OpacitySlider(opacity: $opacity)

        // Example of using the opacity value
        Rectangle()
            .fill(Color.blue)
            .frame(width: 100, height: 100)
            .opacity(opacity)

        Spacer()
    }
    .padding()
}
