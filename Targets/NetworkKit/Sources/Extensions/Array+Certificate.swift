//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

extension [Certificate] {
    /// Extracts the public key (`SecKey`) from each certificate in the array.
    ///
    /// This method iterates through the collection, attempting to create a `SecKey`
    /// from the `publicKey` data of each `Certificate` instance.
    ///
    /// - Note: Certificates that fail to produce a valid `SecKey` are silently
    ///   omitted from the returned array.
    ///
    /// - Returns: An array of `SecKey` objects. Returns an empty array if no
    ///   keys could be extracted.
    func getSecKeys() -> [SecKey] {
        var keys: [SecKey] = []

        for certificate in self {
            if let secKey = SecKey.create(from: certificate.publicKey) {
                keys.append(secKey)
            }
        }

        return keys
    }
}
