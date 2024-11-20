//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Moya
import NetworkKit

public extension Backend {
    convenience init(
        isStubbed: Bool = false,
        stubBehavior: StubBehavior = .immediate
    ) {
        self.init(
            isStubbed: isUITestEnvironment ? true : isStubbed,
            stubBehavior: stubBehavior,
            session: NetworkSession.default
        )
    }
}
