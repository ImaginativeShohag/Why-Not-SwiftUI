//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

public extension Color {
    // MARK: - Text Colors

    static let lightText = Color(UIColor.lightText)
    static let darkText = Color(UIColor.darkText)
    static let placeholderText = Color(UIColor.placeholderText)

    // MARK: - Label Colors

    static let label = Color(UIColor.label)
    static let labelLightVarient = Color(UIColor.label).opacity(0.7)
    static let secondaryLabel = Color(UIColor.secondaryLabel)
    static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    static let quaternaryLabel = Color(UIColor.quaternaryLabel)

    // MARK: - Background Colors

    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(UIColor.tertiarySystemBackground)

    // MARK: - Fill Colors

    static let systemFill = Color(UIColor.systemFill)
    static let secondarySystemFill = Color(UIColor.secondarySystemFill)
    static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
    static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)

    // MARK: - Grouped Background Colors

    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let tertiarySystemGroupedBackground = Color(UIColor.tertiarySystemGroupedBackground)

    // MARK: - Gray Colors

    static let systemGray = Color.gray
    static let systemGrayAccessible = Color("systemGrayAccessible")
    static let systemGray2 = Color(UIColor.systemGray2)
    static let systemGray2Accessible = Color("systemGray2Accessible")
    static let systemGray3 = Color(UIColor.systemGray3)
    static let systemGray3Accessible = Color("systemGray3Accessible")
    static let systemGray4 = Color(UIColor.systemGray4)
    static let systemGray4Accessible = Color("systemGray4Accessible")
    static let systemGray5 = Color(UIColor.systemGray5)
    static let systemGray5Accessible = Color("systemGray5Accessible")
    static let systemGray6 = Color(UIColor.systemGray6)
    static let systemGray6Accessible = Color("systemGray6Accessible")

    // MARK: - Other Colors

    static let separator = Color(UIColor.separator)
    static let opaqueSeparator = Color(UIColor.opaqueSeparator)
    static let link = Color(UIColor.link)

    // MARK: System Colors

    static let systemRed = Color.red
    static let systemRedAccessible = Color("systemRedAccessible")
    static let systemOrange = Color.orange
    static let systemOrangeAccessible = Color("systemOrangeAccessible")
    static let systemYellow = Color.yellow
    static let systemYellowAccessible = Color("systemYellowAccessible")
    static let systemGreen = Color.green
    static let systemGreenAccessible = Color("systemGreenAccessible")
    static let systemMint = Color.mint
    static let systemMintAccessible = Color("systemMintAccessible")
    static let systemTeal = Color.teal
    static let systemTealAccessible = Color("systemTealAccessible")
    static let systemCyan = Color.cyan
    static let systemCyanAccessible = Color("systemCyanAccessible")
    static let systemBlue = Color.blue
    static let systemBlueAccessible = Color("systemBlueAccessible")
    static let systemIndigo = Color.indigo
    static let systemIndigoAccessible = Color("systemIndigoAccessible")
    static let systemPurple = Color.purple
    static let systemPurpleAccessible = Color("systemPurpleAccessible")
    static let systemPink = Color.pink
    static let systemPinkAccessible = Color("systemPinkAccessible")
    static let systemBrown = Color.brown
    static let systemBrownAccessible = Color("systemBrownAccessible")

    static let systemWhite: Color = CoreAsset.systemWhite.swiftUIColor
    static let systemBlack: Color = CoreAsset.systemBlack.swiftUIColor
}
