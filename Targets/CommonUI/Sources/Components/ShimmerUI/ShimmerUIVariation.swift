//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Shimmer
import SwiftUI

public extension ShimmerUI {
    enum Block {}
}

public extension ShimmerUI.Block {
    indirect enum BlockType: Identifiable {
        public var id: String {
            return String(describing: self)
        }
        
        case text(size: Int, line: Int = 1, font: Font = .body)
        case square(size: CGFloat)
        case rectangle(width: CGFloat? = nil, height: CGFloat)
        case rectangleByRatio(ratio: CGFloat, width: CGFloat? = nil)
        case filledCircle(size: CGFloat)
        case outlineCircle(size: CGFloat, lineWidth: CGFloat = 8)
        case vContainer(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat? = 12,
            blocks: [BlockType]
        )
        case hContainer(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat? = 12,
            blocks: [BlockType]
        )
        case vCardContainer(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat? = 12,
            padding: CGFloat? = 12,
            blocks: [BlockType]
        )
        case hCardContainer(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat? = 12,
            padding: CGFloat? = 12,
            blocks: [BlockType]
        )
        case vStack(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat? = 12,
            blocks: [BlockType]
        )
        case hStack(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat? = 12,
            blocks: [BlockType]
        )
        case vGrid(
            iPhoneColumn: Int = 1,
            iPadColumn: Int = 2,
            iPhoneSpacing: CGFloat = 16,
            iPadSpacing: CGFloat = 21,
            alignment: Alignment = .top,
            block: BlockType
        )
        case forEach(count: Int, block: BlockType)
        case spacer
    }
    
    struct ShimmerBlock: View {
        let block: BlockType

        public var body: some View {
            switch self.block {
            case let .text(size, line, font):
                TextBlock(size: size, line: line, font: font)
                
            case let .square(size):
                SquireBlock(size: size)
                
            case let .rectangle(width, height):
                RectangleBlock(width: width, height: height)
                
            case let .rectangleByRatio(ratio, width):
                RectangleBlock(ratio: ratio, width: width)
                
            case let .filledCircle(size):
                FilledCircleBlock(size: size)
                
            case let .outlineCircle(size, lineWidth):
                OutlineCircleBlock(size: size, lineWidth: lineWidth)
                
            case let .vContainer(
                alignment,
                spacing,
                blocks
            ):
                VContainer(alignment: alignment, spacing: spacing, blocks: blocks)
                
            case let .hContainer(
                alignment,
                spacing,
                blocks
            ):
                HContainer(alignment: alignment, spacing: spacing, blocks: blocks)
    
            case let .vCardContainer(
                alignment,
                spacing,
                padding,
                blocks
            ):
                VCardBlock(alignment: alignment, spacing: spacing, padding: padding, blocks: blocks)
    
            case let .hCardContainer(
                alignment,
                spacing,
                padding,
                blocks
            ):
                HCardBlock(alignment: alignment, spacing: spacing, padding: padding, blocks: blocks)
                
            case let .vStack(
                alignment,
                spacing,
                blocks
            ):
                VStackBlock(alignment: alignment, spacing: spacing, blocks: blocks)
                
            case let .hStack(
                alignment,
                spacing,
                blocks
            ):
                HStackBlock(alignment: alignment, spacing: spacing, blocks: blocks)
                
            case let .vGrid(iPhoneColumn, iPadColumn, iPhoneSpacing, iPadSpacing, alignment, block):
                VGridBlock(iPhoneColumn: iPhoneColumn, iPadColumn: iPadColumn, iPhoneSpacing: iPhoneSpacing, iPadSpacing: iPadSpacing, alignment: alignment, block: block)
                
            case let .forEach(count, block):
                ForEach(1 ... count, id: \.self) { _ in
                    ShimmerBlock(block: block)
                }
                
            case .spacer:
                Spacer()
            }
        }
    }
    
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
            return 21 /// For: `.body`
        }
    }
    
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
                ForEach(1 ... self.line, id: \.self) { index in
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

    // MARK: - Squire Block
    
    struct SquireBlock: View {
        let size: CGFloat
        
        public init(size: CGFloat) {
            self.size = size
        }
        
        public var body: some View {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: self.size, height: self.size)
                .foregroundColor(fillColor)
        }
    }

    // MARK: - Rectangle Block
    
    struct RectangleBlock: View {
        let width: CGFloat?
        let height: CGFloat?
        let ratio: CGFloat?
        
        public init(width: CGFloat? = nil, height: CGFloat) {
            self.width = width
            self.height = height
            self.ratio = nil
        }
        
        public init(ratio: CGFloat, width: CGFloat?) {
            self.ratio = ratio
            self.width = width
            self.height = nil
        }
        
        public var body: some View {
            Group {
                if let ratio {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(ratio, contentMode: .fit)
                        .frame(width: self.width)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(maxWidth: .infinity)
                        .frame(width: self.width, height: self.height)
                }
            }
            .foregroundColor(fillColor)
        }
    }
    
    // MARK: - Filled Circle Block
    
    struct FilledCircleBlock: View {
        let size: CGFloat
        
        public init(size: CGFloat) {
            self.size = size
        }
        
        public var body: some View {
            Circle()
                .fill(fillColor)
                .frame(width: self.size, height: self.size)
        }
    }
    
    // MARK: - Outline Circle Block
    
    struct OutlineCircleBlock: View {
        let size: CGFloat
        let lineWidth: CGFloat
        
        public init(size: CGFloat, lineWidth: CGFloat = 8) {
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
    
    struct VCardBlock: View {
        private let alignment: HorizontalAlignment
        private let spacing: CGFloat?
        private let padding: CGFloat?
        private let blocks: [BlockType]
        
        public init(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat? = 12,
            padding: CGFloat? = 12,
            blocks: [BlockType]
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.padding = padding
            self.blocks = blocks
        }
        
        public var body: some View {
            VStack(alignment: self.alignment, spacing: self.spacing) {
                ForEach(self.blocks) { block in
                    ShimmerBlock(block: block)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.all, self.padding)
            .background(Color.secondarySystemGroupedBackground)
            .cornerRadius(8)
        }
    }

    // MARK: - HCard Block
    
    struct HCardBlock: View {
        private let alignment: VerticalAlignment
        private let spacing: CGFloat?
        private let padding: CGFloat?
        private let blocks: [BlockType]
        
        public init(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat? = 12,
            padding: CGFloat? = 12,
            blocks: [BlockType]
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.padding = padding
            self.blocks = blocks
        }
        
        public var body: some View {
            HStack(alignment: self.alignment, spacing: self.spacing) {
                ForEach(self.blocks) { block in
                    ShimmerBlock(block: block)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.all, self.padding)
            .background(Color.secondarySystemGroupedBackground)
            .cornerRadius(8)
        }
    }
    
    // MARK: - VStack Block
    
    struct VStackBlock: View {
        private let alignment: HorizontalAlignment
        private let spacing: CGFloat?
        private let blocks: [BlockType]
        
        public init(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat? = 12,
            blocks: [BlockType]
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.blocks = blocks
        }
        
        public var body: some View {
            VStack(alignment: self.alignment, spacing: self.spacing) {
                ForEach(self.blocks) { block in
                    ShimmerBlock(block: block)
                }
            }
        }
    }

    // MARK: - HStack Block
    
    struct HStackBlock: View {
        private let alignment: VerticalAlignment
        private let spacing: CGFloat?
        private let blocks: [BlockType]
        
        public init(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat? = 12,
            blocks: [BlockType]
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.blocks = blocks
        }
        
        public var body: some View {
            HStack(alignment: self.alignment, spacing: self.spacing) {
                ForEach(self.blocks) { block in
                    ShimmerBlock(block: block)
                }
            }
        }
    }
    
    // MARK: - Grid Block
    
    struct VGridBlock: View {
        private let columns: [GridItem]
        private let spacing: CGFloat
        private let alignment: Alignment
        private let block: BlockType
        
        public init(
            iPhoneColumn: Int = 1,
            iPadColumn: Int = 2,
            iPhoneSpacing: CGFloat = 16,
            iPadSpacing: CGFloat = 21,
            alignment: Alignment = .top,
            block: BlockType
        ) {
            self.spacing = UIDevice.current.isPhone ? iPhoneSpacing : iPadSpacing
            self.columns = Array(
                repeating: GridItem(.flexible(), spacing: self.spacing, alignment: alignment),
                count: UIDevice.current.isPhone ? iPhoneColumn : iPadColumn
            )
            self.alignment = alignment
            self.block = block
        }
    
        public var body: some View {
            LazyVGrid(columns: self.columns, spacing: self.spacing) {
                ShimmerBlock(block: self.block)
            }
        }
    }
    
    // MARK: - Vertical Container Block
    
    struct VContainer: View {
        private let alignment: HorizontalAlignment
        private let spacing: CGFloat?
        private let blocks: [BlockType]
        
        public init(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat? = 12,
            blocks: [BlockType]
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.blocks = blocks
        }
        
        public var body: some View {
            VStack(alignment: self.alignment, spacing: self.spacing) {
                ForEach(self.blocks) { block in
                    ShimmerBlock(block: block)
                }
            }
            .frame(maxWidth: .infinity)
            .redacted(reason: .placeholder)
            .shimmering()
            .accessibilityLabel("Loading")
        }
    }

    // MARK: - Horizontal Container Block
    
    struct HContainer: View {
        private let alignment: VerticalAlignment
        private let spacing: CGFloat?
        private let blocks: [BlockType]
        
        public init(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat? = 12,
            blocks: [BlockType]
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.blocks = blocks
        }
        
        public var body: some View {
            HStack(alignment: self.alignment, spacing: self.spacing) {
                ForEach(self.blocks) { block in
                    ShimmerBlock(block: block)
                }
            }
            .frame(maxWidth: .infinity)
            .redacted(reason: .placeholder)
            .shimmering()
            .accessibilityLabel("Loading")
        }
    }
}

private struct ShimmerUIDemo1: View {
    var body: some View {
        ScrollView {
            ShimmerUI.Block.VContainer(
                alignment: .leading,
                blocks: [
                    .text(size: 25, font: .title3),
                    .text(size: 20, font: .subheadline),
                    .vCardContainer(
                        alignment: .leading,
                        blocks: [
                            .hStack(
                                blocks: [
                                    .text(size: 20, font: .subheadline),
                                    .text(size: 20, font: .subheadline),
                                    .spacer
                                ]
                            ),
                            .text(size: Int.random(in: 20 ... 30), line: 2),
                            .rectangleByRatio(ratio: 1.77),
                            .forEach(
                                count: Int.random(in: 2 ... 3),
                                block: .hStack(
                                    blocks: [
                                        .square(size: 25),
                                        .text(size: Int.random(in: 25 ... 35)),
                                        .spacer
                                    ]
                                )
                            ),
                            .text(size: 15),
                            .rectangle(height: 80),
                            .text(size: 15),
                            .hStack(
                                blocks: [
                                    .rectangleByRatio(ratio: 1.77, width: 120),
                                    .spacer
                                ]
                            )
                        ]
                    ),
                    .spacer
                ]
            )
        }
    }
}

private struct ShimmerUIDemo2: View {
    var body: some View {
        ScrollView {
            ShimmerUI.Block.VContainer(
                alignment: .leading,
                blocks: [
                    .vGrid(
                        block: .forEach(
                            count: Int.random(in: 4 ... 5),
                            block: .hCardContainer(
                                blocks: [
                                    .square(size: 25),
                                    .text(size: Int.random(in: 25 ... 32)),
                                    .spacer,
                                    .filledCircle(size: 15)
                                ]
                            )
                        )
                    ),
                    .text(size: 15),
                    .vGrid(
                        block: .forEach(
                            count: Int.random(in: 3 ... 5),
                            block: .hCardContainer(
                                blocks: [
                                    .square(size: 25),
                                    .text(size: Int.random(in: 25 ... 32)),
                                    .spacer,
                                    .filledCircle(size: 15)
                                ]
                            )
                        )
                    ),
                    .text(size: 15, font: .title3),
                    .text(size: 15, font: .subheadline),
                    .vGrid(
                        block: .forEach(
                            count: Int.random(in: 3 ... 5),
                            block: .hCardContainer(
                                blocks: [
                                    .square(size: 25),
                                    .text(size: Int.random(in: 25 ... 32)),
                                    .spacer,
                                    .filledCircle(size: 15)
                                ]
                            )
                        )
                    )
                ]
            )
        }
    }
}

private struct ShimmerUIDemo3: View {
    var body: some View {
        ScrollView {
            ShimmerUI.Block.VContainer(
                alignment: .leading,
                blocks: [
                    .vGrid(
                        block: .forEach(
                            count: Int.random(in: 3 ... 5),
                            block: .hCardContainer(
                                blocks: [
                                    .vStack(
                                        alignment: .leading,
                                        spacing: 4,
                                        blocks: [
                                            .text(size: Int.random(in: 25 ... 32)),
                                            .text(size: Int.random(in: 20 ... 25)),
                                            .text(size: Int.random(in: 25 ... 32))
                                        ]
                                    ),
                                    .spacer,
                                    .outlineCircle(size: 50)
                                ]
                            )
                        )
                    )
                ]
            )
        }
    }
}

#Preview("Demo 1") {
    ShimmerUIDemo1()
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.systemGroupedBackground)
}

#Preview("Demo 2") {
    ShimmerUIDemo2()
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.systemGroupedBackground)
}

#Preview("Demo 3") {
    ShimmerUIDemo3()
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.systemGroupedBackground)
}
