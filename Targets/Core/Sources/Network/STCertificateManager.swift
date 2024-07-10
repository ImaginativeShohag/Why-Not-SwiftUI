//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Security

final class STCertificateManager {
    static let shared = STCertificateManager()

    // PEM format is the base64 format of a certificate.
    private let pemFormatPublicKeys = [
        // Certificates Hex
        // [0x11, 0x22, 0xAA, 0xBB, ...]
    ]

    let publicKeys: [SecKey]

    private init() {
        var publicKeys: [SecKey] = []

        for pemFormatPublicKey in pemFormatPublicKeys {
            // Hex to String
            let pemFormatPublicKeyStr = String(pemFormatPublicKey.map { Character(UnicodeScalar($0)!) })

            if let certificateData = Data(base64Encoded: pemFormatPublicKeyStr, options: []),
               let certificate = SecCertificateCreateWithData(nil, certificateData as CFData)
            {
                var trust: SecTrust?
                let policy = SecPolicyCreateBasicX509()
                let status = SecTrustCreateWithCertificates(certificate, policy, &trust)

                if status == errSecSuccess, let trust = trust,
                   let publicKey = SecTrustCopyKey(trust)
                {
                    publicKeys.append(publicKey)
                }
            }
        }

        self.publicKeys = publicKeys
    }
}
