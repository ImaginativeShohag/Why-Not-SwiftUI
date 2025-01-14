//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Shimmer
import SwiftUI

public enum ShimmerUI {}

public extension ShimmerUI {
    // MARK: - Text Block

    fileprivate static let fillColor = Color.tertiaryLabel

    /// - Returns: The equivalent `Text` view height for given `font`.
    fileprivate static func getTextHeight(for font: Font) -> CGFloat {
        switch font {
        case .largeTitle:
            return 41

        case .title:
            return 34

        case .title2:
            return 27

        case .title3:
            return 24

        case .headline:
            return 21

        case .body:
            return 21

        case .callout:
            return 20

        case .subheadline:
            return 18

        case .footnote:
            return 16

        case .caption:
            return 15

        case .caption2:
            return 14

        default:
            return 21
            /// For: `.body`
        }
    }

    /// A view displaying shimmering text blocks with specified line count and font.
    struct TextBlock: View {
        private let size: Int
        private let line: Int
        private let font: Font

        public init(size: Int, line: Int = 1, font: Font = .body) {
            self.size = size
            self.line = line
            self.font = font
        }

        public var body: some View {
            let textHeight = getTextHeight(for: font)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(1...self.line, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 0)
                        .fill(fillColor)
                        /// `0.4` is calculated by comparing the size with `.redacted()` `Text` view.
                        .frame(maxWidth: index == self.line ? (textHeight * 0.4) * CGFloat(self.size) : .infinity)
                        /// `0.6` is calculated by comparing the size with `.redacted()` `Text` view.
                        .frame(height: textHeight * 0.6)
                        .clipShape(RoundedRectangle(cornerRadius: .infinity))
                        .frame(height: textHeight)
                }
            }
        }
    }

    // MARK: - Filled Square Block

    @available(
        *,
        deprecated,
        renamed: "FilledSquareBlock",
        message: "Use FilledSquareBlock"
    )
    typealias SquireBlock = FilledSquareBlock

    /// A solid square-shaped shimmering block of a specified size.
    struct FilledSquareBlock: View {
        private let size: CGFloat
        private let cornerRadius: CGFloat
        private let corners: UIRectCorner

        public init(
            size: CGFloat,
            cornerRadius: CGFloat = 8,
            corners: UIRectCorner = .allCorners
        ) {
            self.size = size
            self.cornerRadius = cornerRadius
            self.corners = corners
        }

        public var body: some View {
            Rectangle()
                .frame(width: self.size, height: self.size)
                .foregroundColor(fillColor)
                .cornerRadius(self.cornerRadius, corners: self.corners)
        }
    }

    // MARK: - Bordered Square Block

    /// A bordered Square shimmering block with corner radius and customizable width, height, or aspect ratio.
    struct BorderedSquareBlock: View {
        private let size: CGFloat
        private let cornerRadius: CGFloat
        private let corners: UIRectCorner
        private let lineWidth: CGFloat

        public init(
            size: CGFloat,
            cornerRadius: CGFloat = 8,
            corners: UIRectCorner = .allCorners,
            lineWidth: CGFloat = 8
        ) {
            self.size = size
            self.cornerRadius = cornerRadius
            self.corners = corners
            self.lineWidth = lineWidth
        }

        public var body: some View {
            RoundedCorner(
                radius: self.cornerRadius,
                corners: self.corners
            )
            .stroke(
                style: StrokeStyle(
                    lineWidth: self.lineWidth,
                    lineCap: .square,
                    lineJoin: .miter
                )
            )
            .frame(width: self.size, height: self.size)
            .foregroundColor(fillColor)
        }
    }

    // MARK: - Filled Rectangle Block

    @available(
        *,
        deprecated,
        renamed: "FilledRectangleBlock",
        message: "Use FilledRectangleBlock"
    )
    typealias RectangleBlock = FilledRectangleBlock

    /// A solid rectangular shimmering block with corner radius and customizable width, height, or aspect ratio.
    struct FilledRectangleBlock: View {
        private let width: CGFloat?
        private let height: CGFloat?
        private let cornerRadius: CGFloat
        private let corners: UIRectCorner
        private let ratio: CGFloat?

        public init(
            width: CGFloat? = nil,
            height: CGFloat,
            cornerRadius: CGFloat = 8,
            corners: UIRectCorner = .allCorners
        ) {
            self.width = width
            self.height = height
            self.cornerRadius = cornerRadius
            self.corners = corners
            self.ratio = nil
        }

        public init(
            ratio: CGFloat,
            cornerRadius: CGFloat = 8,
            corners: UIRectCorner = .allCorners
        ) {
            self.ratio = ratio
            self.cornerRadius = cornerRadius
            self.corners = corners
            self.width = nil
            self.height = nil
        }

        public var body: some View {
            Group {
                if let ratio {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(ratio, contentMode: .fit)
                        .cornerRadius(self.cornerRadius, corners: self.corners)
                } else {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(width: self.width, height: self.height)
                        .cornerRadius(self.cornerRadius, corners: self.corners)
                }
            }
            .foregroundColor(fillColor)
        }
    }

    // MARK: - Bordered Rectangle Block

    /// A bordered rectangular shimmering block with corner radius and customizable width, height, or aspect ratio.
    struct BorderedRectangleBlock: View {
        private let width: CGFloat?
        private let height: CGFloat?
        private let cornerRadius: CGFloat
        private let corners: UIRectCorner
        private let ratio: CGFloat?
        private let lineWidth: CGFloat

        public init(
            width: CGFloat? = nil,
            height: CGFloat,
            cornerRadius: CGFloat = 8,
            corners: UIRectCorner = .allCorners,
            lineWidth: CGFloat = 8
        ) {
            self.width = width
            self.height = height
            self.cornerRadius = cornerRadius
            self.corners = corners
            self.ratio = nil
            self.lineWidth = lineWidth
        }

        public init(
            ratio: CGFloat,
            cornerRadius: CGFloat = 8,
            corners: UIRectCorner = .allCorners,
            lineWidth: CGFloat = 8
        ) {
            self.ratio = ratio
            self.cornerRadius = cornerRadius
            self.corners = corners
            self.lineWidth = lineWidth
            self.width = nil
            self.height = nil
        }

        public var body: some View {
            Group {
                if let ratio {
                    RoundedCorner(
                        radius: self.cornerRadius,
                        corners: self.corners
                    )
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: self.lineWidth,
                            lineCap: .square,
                            lineJoin: .miter
                        )
                    )
                    .frame(maxWidth: .infinity)
                    .aspectRatio(ratio, contentMode: .fit)
                } else {
                    RoundedCorner(
                        radius: self.cornerRadius,
                        corners: self.corners
                    )
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: self.lineWidth,
                            lineCap: .square,
                            lineJoin: .miter
                        )
                    )
                    .frame(maxWidth: .infinity)
                    .frame(width: self.width, height: self.height)
                }
            }
            .foregroundColor(fillColor)
        }
    }

    // MARK: - Filled Circle Block

    /// A solid circular shimmering block of a specified size.
    struct FilledCircleBlock: View {
        private let size: CGFloat

        public init(size: CGFloat) {
            self.size = size
        }

        public var body: some View {
            Circle()
                .fill(fillColor)
                .frame(width: self.size, height: self.size)
        }
    }

    // MARK: - Bordered Circle Block

    @available(
        *,
        deprecated,
        renamed: "BorderedCircleBlock",
        message: "Use BorderedCircleBlock"
    )
    typealias OutlineCircleBlock = BorderedCircleBlock

    /// A bordered circular shimmering outline block with customizable size and line width.
    struct BorderedCircleBlock: View {
        private let size: CGFloat
        private let lineWidth: CGFloat

        public init(
            size: CGFloat,
            lineWidth: CGFloat = 8
        ) {
            self.size = size
            self.lineWidth = lineWidth
        }

        public var body: some View {
            Circle()
                .stroke(lineWidth: self.lineWidth)
                .fill(fillColor)
                .frame(width: self.size, height: self.size)
        }
    }

    // MARK: - VCard Block

    /// A vertically-aligned card view with padding and customizable alignment and spacing.
    struct VCardBlock<Content: View>: View {
        private let alignment: HorizontalAlignment
        private let spacing: CGFloat?
        private let padding: CGFloat?
        private let cornerRadius: CGFloat
        private let corners: UIRectCorner
        private let backgroundColor: Color
        @ViewBuilder private let content: () -> Content

        public init(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat? = 12,
            padding: CGFloat? = 12,
            cornerRadius: CGFloat = 8,
            corners: UIRectCorner = .allCorners,
            backgroundColor: Color = Color.secondarySystemGroupedBackground,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.padding = padding
            self.cornerRadius = cornerRadius
            self.corners = corners
            self.backgroundColor = backgroundColor
            self.content = content
        }

        public var body: some View {
            VStack(alignment: self.alignment, spacing: self.spacing) {
                self.content()
            }
            .frame(
                maxWidth: .infinity,
                alignment: Alignment(
                    horizontal: self.alignment,
                    vertical: .center
                )
            )
            .padding(.all, self.padding)
            .background(self.backgroundColor)
            .cornerRadius(self.cornerRadius, corners: self.corners)
        }
    }

    // MARK: - HCard Block

    /// A horizontally-aligned card view with padding and customizable alignment and spacing.
    struct HCardBlock<Content: View>: View {
        private let alignment: VerticalAlignment
        private let spacing: CGFloat?
        private let padding: CGFloat?
        private let cornerRadius: CGFloat
        private let corners: UIRectCorner
        private let backgroundColor: Color
        @ViewBuilder private let content: () -> Content

        public init(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat? = 12,
            padding: CGFloat? = 12,
            cornerRadius: CGFloat = 8,
            corners: UIRectCorner = .allCorners,
            backgroundColor: Color = Color.secondarySystemGroupedBackground,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.padding = padding
            self.cornerRadius = cornerRadius
            self.corners = corners
            self.backgroundColor = backgroundColor
            self.content = content
        }

        public var body: some View {
            HStack(alignment: self.alignment, spacing: self.spacing) {
                self.content()
            }
            .frame(
                maxWidth: .infinity,
                alignment: Alignment(
                    horizontal: .center,
                    vertical: self.alignment
                )
            )
            .padding(.all, self.padding)
            .background(self.backgroundColor)
            .cornerRadius(self.cornerRadius, corners: self.corners)
        }
    }

    // MARK: - VStack Block

    /// A vertical stack block with customizable alignment and spacing.
    struct VStackBlock<Content: View>: View {
        private let alignment: HorizontalAlignment
        private let spacing: CGFloat?
        @ViewBuilder private let content: () -> Content

        public init(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat? = 12,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.content = content
        }

        public var body: some View {
            VStack(alignment: self.alignment, spacing: self.spacing) {
                self.content()
            }
        }
    }

    // MARK: - HStack Block

    /// A horizontal stack block with customizable alignment and spacing.
    struct HStackBlock<Content: View>: View {
        private let alignment: VerticalAlignment
        private let spacing: CGFloat?
        @ViewBuilder private let content: () -> Content

        public init(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat? = 12,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.content = content
        }

        public var body: some View {
            HStack(alignment: self.alignment, spacing: self.spacing) {
                self.content()
            }
        }
    }

    // MARK: - Grid Block

    /// A vertical grid block that adapts for iPhone and iPad with specified columns and spacing.
    struct VGridBlock<Content: View>: View {
        private let columns: [GridItem]
        private let spacing: CGFloat
        private let alignment: Alignment
        @ViewBuilder private let content: () -> Content

        public init(
            iPhoneColumn: Int = 1,
            iPadColumn: Int = 2,
            iPhoneSpacing: CGFloat = 16,
            iPadSpacing: CGFloat = 21,
            alignment: Alignment = .top,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.spacing =
                UIDevice.current.isPhone ? iPhoneSpacing : iPadSpacing
            self.columns = Array(
                repeating: GridItem(
                    .flexible(), spacing: self.spacing, alignment: alignment
                ),
                count: UIDevice.current.isPhone ? iPhoneColumn : iPadColumn
            )
            self.alignment = alignment
            self.content = content
        }

        public var body: some View {
            LazyVGrid(columns: self.columns, spacing: self.spacing) {
                self.content()
            }
        }
    }

    // MARK: - ForEach Block

    /// A block that repeats a view a specified number of times.
    struct ForEachBlock<Content: View>: View {
        private let count: Int

        @ViewBuilder private let content: () -> Content

        public init(
            count: Int,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.count = count
            self.content = content
        }

        public var body: some View {
            ForEach(1...self.count, id: \.self) { _ in
                self.content()
            }
        }
    }

    // MARK: - Vertical Container Block

    /// A vertically-aligned container with shimmering placeholder and customizable alignment and spacing.
    struct VContainer<Content: View>: View {
        private let alignment: HorizontalAlignment
        private let spacing: CGFloat?
        @ViewBuilder private let content: () -> Content

        public init(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat? = 12,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.content = content
        }

        public var body: some View {
            VStack(alignment: self.alignment, spacing: self.spacing) {
                self.content()
            }
            .frame(
                maxWidth: .infinity,
                alignment: Alignment(
                    horizontal: self.alignment,
                    vertical: .center
                )
            )
            .redacted(reason: .placeholder)
            .shimmering()
            .accessibilityLabel("Loading")
        }
    }

    // MARK: - Horizontal Container Block

    /// A horizontally-aligned container with shimmering placeholder and customizable alignment and spacing.
    struct HContainer<Content: View>: View {
        private let alignment: VerticalAlignment
        private let spacing: CGFloat?
        @ViewBuilder private let content: () -> Content

        public init(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat? = 12,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.content = content
        }

        public var body: some View {
            HStack(alignment: self.alignment, spacing: self.spacing) {
                self.content()
            }
            .frame(
                maxWidth: .infinity,
                alignment: Alignment(
                    horizontal: .center,
                    vertical: self.alignment
                )
            )
            .redacted(reason: .placeholder)
            .shimmering()
            .accessibilityLabel("Loading")
        }
    }
}
