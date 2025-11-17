//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

public extension Encodable {
    /// Converts the conforming `Encodable` object to `Data`.
    ///
    /// - Returns: The JSON-encoded `Data` representation of the object, or `nil` if encoding fails.
    func toData() -> Data? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return data
        } catch {
            print("Error encoding object: \(error)")
            return nil
        }
    }

    /// Convert the `Encodable` object to JSON `String`.
    ///
    /// - Returns: The JSON string for the `Encodable`. If it fails, it will throw an exception.
    ///
    /// - Note: Tested: `EncodableToJsonStringTests`
    func toJSONString() throws -> String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .sortedKeys
        let jsonData = try jsonEncoder.encode(self)
        return String(data: jsonData, encoding: .utf8)
    }
}
