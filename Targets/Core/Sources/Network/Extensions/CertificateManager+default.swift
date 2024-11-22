//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import NetworkKit

public extension CertificateManager {
    static var `default`: CertificateManager {
        return CertificateManager(keys: [
            // [0x11, 0x22, 0xAA, 0xBB, ...],
            // [0x33, 0x44, 0xCC, 0xDD, ...]
        ])
    }
}
