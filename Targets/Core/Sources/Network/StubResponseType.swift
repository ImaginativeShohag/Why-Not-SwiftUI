//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

public enum StubResponseType {
    case disabled
    
    // Server successfully gave response. It will be 2XX response.
    case success
    
    // Server failed to gave response. It will be other then 2XX response.
    case failure
    
    // Server successfully gave response, but it is error response.
    // It will be 2XX response.
    case error
}
