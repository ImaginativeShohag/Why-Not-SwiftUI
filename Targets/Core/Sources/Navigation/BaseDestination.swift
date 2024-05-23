//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

open class BaseDestination: @unchecked Sendable {
    public var route: String {
        String(describing: type(of: self))
    }

    public init() {}

    @MainActor
    @ViewBuilder
    open func getScreen() -> any View {
        fatalError("Not implemented!")
    }
}
