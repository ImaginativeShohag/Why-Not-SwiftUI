// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum WhyNotSwiftUIFontFamily {
  public enum RobotoSlab {
    public static let black = WhyNotSwiftUIFontConvertible(name: "RobotoSlab-Black", family: "Roboto Slab", path: "RobotoSlab-VariableFont.ttf")
    public static let bold = WhyNotSwiftUIFontConvertible(name: "RobotoSlab-Bold", family: "Roboto Slab", path: "RobotoSlab-VariableFont.ttf")
    public static let extraBold = WhyNotSwiftUIFontConvertible(name: "RobotoSlab-ExtraBold", family: "Roboto Slab", path: "RobotoSlab-VariableFont.ttf")
    public static let extraLight = WhyNotSwiftUIFontConvertible(name: "RobotoSlab-ExtraLight", family: "Roboto Slab", path: "RobotoSlab-VariableFont.ttf")
    public static let light = WhyNotSwiftUIFontConvertible(name: "RobotoSlab-Light", family: "Roboto Slab", path: "RobotoSlab-VariableFont.ttf")
    public static let medium = WhyNotSwiftUIFontConvertible(name: "RobotoSlab-Medium", family: "Roboto Slab", path: "RobotoSlab-VariableFont.ttf")
    public static let regular = WhyNotSwiftUIFontConvertible(name: "RobotoSlab-Regular", family: "Roboto Slab", path: "RobotoSlab-VariableFont.ttf")
    public static let semiBold = WhyNotSwiftUIFontConvertible(name: "RobotoSlab-SemiBold", family: "Roboto Slab", path: "RobotoSlab-VariableFont.ttf")
    public static let thin = WhyNotSwiftUIFontConvertible(name: "RobotoSlab-Thin", family: "Roboto Slab", path: "RobotoSlab-VariableFont.ttf")
    public static let all: [WhyNotSwiftUIFontConvertible] = [black, bold, extraBold, extraLight, light, medium, regular, semiBold, thin]
  }
  public enum SFProRounded {
    public static let black = WhyNotSwiftUIFontConvertible(name: "SFProRounded-Black", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Black.otf")
    public static let bold = WhyNotSwiftUIFontConvertible(name: "SFProRounded-Bold", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Bold.otf")
    public static let heavy = WhyNotSwiftUIFontConvertible(name: "SFProRounded-Heavy", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Heavy.otf")
    public static let light = WhyNotSwiftUIFontConvertible(name: "SFProRounded-Light", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Light.otf")
    public static let medium = WhyNotSwiftUIFontConvertible(name: "SFProRounded-Medium", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Medium.otf")
    public static let regular = WhyNotSwiftUIFontConvertible(name: "SFProRounded-Regular", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Regular.otf")
    public static let semibold = WhyNotSwiftUIFontConvertible(name: "SFProRounded-Semibold", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Semibold.otf")
    public static let thin = WhyNotSwiftUIFontConvertible(name: "SFProRounded-Thin", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Thin.otf")
    public static let ultralight = WhyNotSwiftUIFontConvertible(name: "SFProRounded-Ultralight", family: "SF Pro Rounded", path: "SF-Pro-Rounded-Ultralight.otf")
    public static let all: [WhyNotSwiftUIFontConvertible] = [black, bold, heavy, light, medium, regular, semibold, thin, ultralight]
  }
  public static let allCustomFonts: [WhyNotSwiftUIFontConvertible] = [RobotoSlab.all, SFProRounded.all].flatMap { $0 }
  public static func registerAllCustomFonts() {
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct WhyNotSwiftUIFontConvertible {
  public let name: String
  public let family: String
  public let path: String

  #if os(macOS)
  public typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Font = UIFont
  #endif

  public func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    #if os(macOS)
    return SwiftUI.Font.custom(font.fontName, size: font.pointSize)
    #elseif os(iOS) || os(tvOS) || os(watchOS)
    return SwiftUI.Font(font)
    #endif
  }
  #endif

  public func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return Bundle.module.url(forResource: path, withExtension: nil)
  }
}

public extension WhyNotSwiftUIFontConvertible.Font {
  convenience init?(font: WhyNotSwiftUIFontConvertible, size: CGFloat) {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: font.family).contains(font.name) {
      font.register()
    }
    #elseif os(macOS)
    if let url = font.url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      font.register()
    }
    #endif

    self.init(name: font.name, size: size)
  }
}
// swiftlint:enable all
// swiftformat:enable all
