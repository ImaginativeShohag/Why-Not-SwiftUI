//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// Tested: `UserDefaultTests`

// MARK: - `UserDefault`

@propertyWrapper
public struct UserDefault<T: PropertyListValue> {
    let key: Key
    let defaultValue: T?

    init(key: Key, defaultValue: T? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T? {
        get { UserDefaults.standard.value(forKey: key.rawValue) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key.rawValue) }
    }

    /// The ``UserDefault/projectedValue`` is the property accessed with the `$` operator.
    public var projectedValue: UserDefault<T> { return self }

    func observe(change: @escaping (T?, T?) -> Void) -> NSObject {
        return UserDefaultsObservation(key: key) { old, new in
            change(old as? T, new as? T)
        }
    }
}

// MARK: - `CodableUserDefault`

@propertyWrapper
public struct CodableUserDefault<T: Codable> {
    let key: Key
    let defaultValue: T?

    init(key: Key, defaultValue: T? = nil) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T? {
        get {
            if let objectData = UserDefaults.standard.value(forKey: key.rawValue) as? Data {
                let decoder = JSONDecoder()
                if let decodedObject = try? decoder.decode(T.self, from: objectData) {
                    return decodedObject
                }
            }

            return defaultValue
        }
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.set(encoded, forKey: key.rawValue)
            }
        }
    }

    public var projectedValue: CodableUserDefault<T> { return self }

    func observe(change: @escaping (T?, T?) -> Void) -> NSObject {
        return UserDefaultsObservation(key: key) { old, new in
            change(old as? T, new as? T)
        }
    }
}

// MARK: -

public struct Key: RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Key: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        rawValue = stringLiteral
    }
}

extension Key: Sendable {}

// The marker protocol
public protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Date: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}

// Every element must be a property-list type
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}
