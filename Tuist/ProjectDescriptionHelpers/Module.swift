//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

public struct Module {
    let name: String
    let hasResources: Bool
    let dependencies: [String]

    public init(name: String, hasResources: Bool = false, dependencies: [String] = []) {
        self.name = name
        self.hasResources = hasResources
        self.dependencies = dependencies
    }
}
