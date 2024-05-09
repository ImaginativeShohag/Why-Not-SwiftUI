//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

public extension Color {
    static let theme = ColorTheme()
}

public struct ColorTheme {
    public let white = CoreAsset.white.swiftUIColor
    public let black = CoreAsset.black.swiftUIColor
    public let red500 = CoreAsset.red500.swiftUIColor
}
