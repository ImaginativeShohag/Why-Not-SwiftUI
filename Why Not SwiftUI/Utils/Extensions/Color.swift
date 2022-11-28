//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let white = Color("White")
    let black = Color("Black")
    
    let red500 = Color("Red500")
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

extension Color {
    /// String HEX value to `Color`.
    init(hex string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }

        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }

        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }

        // Scanner creation
        let scanner = Scanner(string: string)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        if string.count == 2 {
            let mask = 0xff

            let g = Int(color) & mask

            let gray = Double(g)/255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)
        }
        else if string.count == 4 {
            let mask = 0x00ff

            let g = Int(color >> 8) & mask
            let a = Int(color) & mask

            let gray = Double(g)/255.0
            let alpha = Double(a)/255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)
        }
        else if string.count == 6 {
            let mask = 0x0000ff
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = Double(r)/255.0
            let green = Double(g)/255.0
            let blue = Double(b)/255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
        }
        else if string.count == 8 {
            let mask = 0x000000ff
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask

            let red = Double(r)/255.0
            let green = Double(g)/255.0
            let blue = Double(b)/255.0
            let alpha = Double(a)/255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        }
        else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }

    /// `Color` to `UIColor`
    func uiColor() -> UIColor {
        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let scanner = Scanner(string: description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24)/255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16)/255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8)/255
            a = CGFloat(hexNumber & 0x000000ff)/255
        }
        return (r, g, b, a)
    }
}
