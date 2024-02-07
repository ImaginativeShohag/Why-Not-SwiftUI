//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import Home
import SwiftUI

enum DestinationMapper {
    @ViewBuilder
    static func getScreen(destination: BaseDestination) -> some View {
        if let destination = destination as? HomeDestination {
            HomeDestination.getScreen(for: destination)
        }
    }
}
