//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SuperLog

extension SecKey {
    /// Creates a `SecKey` instance by extracting the public key from a certificate.
    ///
    /// - Parameter certificateBytes: An array of bytes (`[UInt8]`) representing an X.509 certificate.
    /// - Returns: A `SecKey` object representing the public key if it can be successfully extracted.
    ///   Returns `nil` if the provided data is not a valid certificate or if the key extraction fails for any reason.
    static func create(from certificateBytes: [UInt8]) -> SecKey? {
        let certificateData = Data(certificateBytes)
        if let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) {
            var trust: SecTrust?
            let policy = SecPolicyCreateBasicX509()
            let status = SecTrustCreateWithCertificates(certificate, policy, &trust)

            if status == errSecSuccess,
               let trust = trust,
               let publicKey = SecTrustCopyKey(trust)
            {
                return publicKey
            }

            #if DEBUG
                if status != errSecSuccess {
                    if let errorString = SecCopyErrorMessageString(status, nil) {
                        SuperLog.w("Failed to create SecTrust. Error Message: \(errorString)")
                    } else {
                        SuperLog.w("Failed to create SecTrust. Error Code: \(status)")
                    }
                }
            #endif
        }

        #if DEBUG
            SuperLog.w("Failed to create SecKey from certificate bytes.")
        #endif

        return nil
    }
}
