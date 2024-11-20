//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Security

public extension SecKey {
    /// Extension for `SecKey` to create a `SecKey` from a PEM-encoded public key.
    ///
    /// This method allows you to convert a PEM-encoded public key (provided as a list of integers representing
    /// the hexadecimal values of the base64-encoded certificate) into a `SecKey` instance. It decodes the PEM
    /// format, processes the certificate, and extracts the public key if the certificate is valid.
    ///
    /// - Parameter pem: An array of integers where each integer represents a byte in the PEM-encoded public key.
    /// - Returns: A `SecKey` instance representing the public key if successful, or `nil` if the process fails.
    ///
    /// This method follows these steps:
    /// 1. Converts the PEM array of hex values into a string.
    /// 2. Base64-decodes the string to obtain the certificate data.
    /// 3. Creates a certificate from the decoded data.
    /// 4. Uses a basic X.509 policy to evaluate the certificate trust.
    /// 5. Extracts the public key from the trusted certificate if evaluation succeeds.
    ///
    /// If any step fails (e.g., invalid PEM, certificate creation failure, or trust evaluation failure), `nil` is returned.
    ///
    /// To convert any PEM file into a hexadecimal array suitable for use here, you can use the following terminal command:
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
    /// You can replace `yourfile.pem` with the path to your PEM file.
    ///
    /// # Why using array of integer?
    ///
    ///
    
    /// Converts a PEM file represented as an array of integers into a `SecKey` object.
    ///
    /// - Parameter pem: An array of integers representing the Unicode scalar values (hex values) of the PEM-encoded certificate content.
    /// - Returns: A `SecKey` object representing the public key, or `nil` if the conversion or validation fails.
    static func fromPEM(_ pem: [Int]) -> SecKey? {
        // Convert the integer array into a String by mapping each integer to its Unicode scalar character.
        let pemStr = String(pem.map { Character(UnicodeScalar($0)!) })
        
        // Decode the PEM string from Base64 into a `Data` object.
        // This step assumes the input string is a valid Base64-encoded DER certificate.
        if let certificateData = Data(base64Encoded: pemStr, options: []),
           
           // Create a `SecCertificate` object from the decoded certificate data.
           let certificate = SecCertificateCreateWithData(nil, certificateData as CFData)
        {
            // Create a trust object using the certificate and a basic X.509 policy.
            var trust: SecTrust?
            let policy = SecPolicyCreateBasicX509()
            let status = SecTrustCreateWithCertificates(certificate, policy, &trust)
            
            // If the trust is successfully created and validated, extract the public key from the trust object.
            if status == errSecSuccess, let trust = trust,
               let publicKey = SecTrustCopyKey(trust)
            {
                return publicKey // Return the public key if everything is successful.
            }
        }

        // Return `nil` if any step fails (e.g., decoding, certificate creation, or trust validation).
        return nil
    }
}
