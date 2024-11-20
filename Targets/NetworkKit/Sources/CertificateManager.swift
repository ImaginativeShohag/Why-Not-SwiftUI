//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Security

/// `CertificateManager` is responsible for managing public keys extracted from certificates.
/// This class reads certificates in PEM format (base64-encoded), decodes them, and retrieves the public keys.
/// The public keys are then stored in the `publicKeys` property.
public final class CertificateManager {
    /// An array of `SecKey` objects, each representing a public key from a certificate.
    ///
    /// The `publicKeys` array stores public keys parsed from the `keys` parameter.
    /// These keys are extracted from each certificate and can be used for cryptographic operations.
    public let publicKeys: [SecKey]

    /// Private initializer for `CertificateManager`.
    ///
    /// - Parameter pem: An array of integers representing the Unicode scalar values (hex values) of the PEM-encoded certificate content.
    ///
    /// # PEM format public key
    ///
    /// PEM format public keys represented as arrays of hexadecimal integers.
    ///
    /// Each array within `pemFormatPublicKeys` represents a PEM format certificate in hexadecimal.
    /// PEM (Privacy-Enhanced Mail) files are commonly used to encode certificates and keys in a text format.
    /// A PEM file contains a base64-encoded certificate, wrapped with specific header and footer lines:
    /// `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE-----`.
    /// The hex arrays in this property are converted to base64 strings, which are then processed to extract public keys.
    ///
    /// If you need to convert a PEM file into a hexadecimal array that can be used in this property, you can use the following terminal command:
    ///
    /// ```bash
    /// sed '/-----/d' yourfile.pem | tr -d '\r\n' | xxd -p | tr -d '\r\n' | sed 's/../0x&, /g' | sed 's/, $//' | pbcopy && pbpaste
    /// ```
    ///
    /// ### Description of the command:
    /// 1. **`sed '/-----/d' yourfile.pem`**: Removes any lines containing `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE-----` from the PEM file, effectively discarding the certificate headers and footers.
    /// 2. **`tr -d '\n'`**: Removes any newline characters, resulting in a single continuous string of the certificate's base64-encoded data.
    /// 3. **`xxd -p`**: Converts the base64 content into a plain hexadecimal format (using the ASCII-encoded values).
    /// 4. **`tr -d '\n'`**: Removes any newlines left in the hexadecimal output, creating a continuous hex stream.
    /// 5. **`sed 's/../0x&, /g'`**: Adds the `0x` prefix to each byte of the hex output and separates them with commas for readability.
    /// 6. **`sed 's/, $//'`**: Removes the trailing comma and space from the last hexadecimal byte in the string.
    /// 7. **`pbcopy && pbpaste`**: Copies the result to the clipboard and prints it to the terminal so you can easily paste the formatted output.
    ///
    /// This process will give you a hexadecimal array that can be directly copied into this `keys` parameter as shown:
    ///
    /// ```swift
    /// let certificateManager = CertificateManager(keys: [
    ///     [0x11, 0x22, 0xAA, 0xBB, ...],
    ///     [0x33, 0x44, 0xCC, 0xDD, ...]
    /// ])
    /// ```
    ///
    /// You can replace `yourfile.pem` with the path to your PEM file in the command above.
    public init(keys pemFormatPublicKeys: [[Int]]) {
        var publicKeys: [SecKey] = []

        // Loop through each PEM-formatted public key in hexadecimal
        for pemFormatPublicKey in pemFormatPublicKeys {
            if let publicKey = SecKey.fromPEM(pemFormatPublicKey) {
                publicKeys.append(publicKey)
            }
        }

        self.publicKeys = publicKeys
    }
}
