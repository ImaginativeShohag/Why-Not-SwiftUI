//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

public struct Certificate: Sendable {
    /**
     * The public key for certificate pinning, stored as an array of bytes.
     *
     * We store the raw binary data of the certificate's public key as an array of bytes (using hex representation).
     *
     * This is because string literals are compiled directly into the application's binary,
     * making them easily discoverable with command-line tools. For example:
     *
     * ```bash
     * strings AppBinaryFile | grep "BEGIN PUBLIC KEY"
     * ```
     *
     * - Note: This technique is a form of obfuscation, not encryption. Its purpose is to
     * prevent the key from appearing as a readable string in the binary, making it more
     * difficult to find through casual inspection.
     *
     * ## Instructions for creating byte arrays
     *
     * ### For `.pem`(Base64 encoded certificate) file
     *
     * Run the following command in the terminal from the same directory where your `certificate.pem` file is located, and the bytes array will be in the clipboard.
     *
     * ```bash
     * cat certificate.pem \
     *  | sed '/-----/d' \
     *  | tr -d '\n\r ' \
     *  | base64 --decode \
     *  | hexdump -v -e '1/1 "0x%02x, "' \
     *  | sed -e 's/, $//' -e 's/^/[/' -e 's/$/]/' \
     *  | pbcopy
     * ```
     *
     * Explanation:
     * 1. `cat certificate.pem`: Reads the file content.
     * 2. `sed '/-----/d'`: Deletes the header/footer lines.
     * 3. `tr -d '\n\r'`: Removes all newlines, carriage returns, and spaces.
     * 4. `base64 -d`: Decodes the base64 string to binary.
     * 5. `hexdump -v -e '1/1 "0x%02x, "'`: Converts each byte to its hex representation.
     * 6. `sed -e 's/, $//' -e 's/^/[/' -e 's/$/]/'`: Cleans and formats the string:
     * - - `s/, $//`: Removes the trailing comma and space.
     * - - `s/^/[/`: Adds an opening bracket [ at the beginning.
     * - - `s/$/]/`: Adds a closing bracket ] at the end.
     * 7. `pbcopy`: Copies the final, formatted string to the clipboard.
     *
     * ### For `.der` (binary format of the certificate) file
     *
     * Since `.der` files are already in binary format, no base64 decoding is needed. We will run the following command in the terminal from the same directory where your `certificate.der` file is located, and the bytes array will be in the clipboard.
     *
     * ```bash
     * hexdump -v -e '1/1 "0x%02x, "' certificate.der \
     *  | sed -e 's/, $//' -e 's/^/[/' -e 's/$/]/' \
     *  | pbcopy
     * ```
     *
     * Explanation: Check the explanation above for `.pem` type.
     */
    public let rawPublicKeyBytes: [UInt8]
    
    /**
     * Creates a `Certificate` instance from an array of raw certificate bytes.
     *
     * This initializer is used to construct a certificate object from the binary representation
     * of a certificate's public key. The bytes should be obtained by converting a certificate
     * file (`.pem` or `.der`) into a hexadecimal byte array.
     *
     * - Parameter bytes: An array of unsigned 8-bit integers representing the raw binary data
     *   of the certificate's public key. This data is typically extracted from a `.pem` or `.der`
     *   certificate file using command-line tools.
     *
     * - Note: For instructions on how to generate the byte array from certificate files,
     *   see the documentation on the `rawPublicKeyBytes` property.
     *
     * ## Example
     * ```swift
     * let certificate = Certificate(fromBytes: [
     *     0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09,
     *     // ... additional bytes
     * ])
     * ```
     */
    public init(fromBytes bytes: [UInt8]) {
        self.rawPublicKeyBytes = bytes
    }
}
