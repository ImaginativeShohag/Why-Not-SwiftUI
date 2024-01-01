//
//  Dictionary+.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 07/09/2023.
//

import Foundation

public extension Dictionary where Value == Any {
    /// Access dictionary value with ease.
    ///
    /// Example usage:
    /// ```swift
    /// let coins = dictionary.value(forKey: "numberOfCoins", defaultValue: 100)
    /// ```
    ///
    /// - Parameters:
    ///   - key: Dictionary key.
    ///   - defaultValue: Default value.
    /// - Returns: Respective value or `defaultValue`.
    func value<T>(forKey key: Key, defaultValue: @autoclosure () -> T) -> T {
        guard let value = self[key] as? T else {
            return defaultValue()
        }

        return value
    }
}
