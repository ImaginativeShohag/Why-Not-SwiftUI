// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "CustomMacros", type: "StringifyMacro")


/// Source: https://www.avanderlee.com/swift/macros/
///
/// A macro that produces an unwrapped URL in case of a valid input URL.
/// For example,
///
///     #URL("https://imaginativeworld.org")
///
/// produces an unwrapped `URL` if the URL is valid. Otherwise, it emits a compile-time error.
@freestanding(expression)
public macro URL(_ stringLiteral: String) -> URL = #externalMacro(module: "CustomMacros", type: "URLMacro")

/// Source: https://betterprogramming.pub/use-swift-macros-to-initialize-a-structure-516728c5fb49
@attached(member, names: named(init))
public macro StructInit() = #externalMacro(module: "CustomMacros", type: "StructInitMacro")
