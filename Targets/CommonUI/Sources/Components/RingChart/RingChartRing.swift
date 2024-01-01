//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

public struct RingChartRing: Identifiable {
    public let id: String
    public let progress: CGFloat
    public let color: Color

    public init(
        id: String = UUID().uuidString,
        progress: CGFloat,
        color: Color
    ) {
        self.id = id
        self.progress = progress
        self.color = color
    }
}
