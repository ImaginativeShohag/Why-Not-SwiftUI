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
    
    // Custom response.
    case custom(model: Codable)
    
    // TODO: - we can pass model for all case (eg., success etc.), the model will be optional, if user give any model then we will use then, or predefined model will be used.
    // We also could need to call multi ple apis? then what happen???
}
