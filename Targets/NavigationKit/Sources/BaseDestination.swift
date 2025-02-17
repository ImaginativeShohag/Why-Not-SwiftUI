//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

@MainActor
open class BaseDestination {
    public var route: String {
        String(describing: type(of: self))
    }

    public init() {}

    @ViewBuilder
    open func getScreen() -> any View {
        fatalError("Not implemented!")
    }
}
