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
        
        public init(ratio: CGFloat) {
            self.ratio = ratio
            self.width = nil
            self.height = nil
        }
        
        public var body: some View {
            Group {
                if let ratio {
                    RoundedRectangle(cornerRadius: 8)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(ratio, contentMode: .fit)
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
    
    struct VCardBlock<Content: View>: View {
        private let alignment: HorizontalAlignment
        private let spacing: CGFloat?
        private let padding: CGFloat?
        @ViewBuilder private let content: () -> Content
        
        public init(
            alignment: HorizontalAlignment = .center,
            spacing: CGFloat? = 12,
            padding: CGFloat? = 12,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.padding = padding
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
            .background(Color.secondarySystemGroupedBackground)
            .cornerRadius(8)
        }
    }

    // MARK: - HCard Block
    
    struct HCardBlock<Content: View>: View {
        private let alignment: VerticalAlignment
        private let spacing: CGFloat?
        private let padding: CGFloat?
        @ViewBuilder private let content: () -> Content
        
        public init(
            alignment: VerticalAlignment = .center,
            spacing: CGFloat? = 12,
            padding: CGFloat? = 12,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.padding = padding
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
            .background(Color.secondarySystemGroupedBackground)
            .cornerRadius(8)
        }
    }
    
    // MARK: - VStack Block
    
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
            self.spacing = UIDevice.current.isPhone ? iPhoneSpacing : iPadSpacing
            self.columns = Array(
                repeating: GridItem(.flexible(), spacing: self.spacing, alignment: alignment),
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
            ForEach(1 ... self.count, id: \.self) { _ in
                self.content()
            }
        }
    }
    
    // MARK: - Vertical Container Block
    
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
