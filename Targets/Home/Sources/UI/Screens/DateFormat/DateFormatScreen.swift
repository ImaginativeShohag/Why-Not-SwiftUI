//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class DateFormat: BaseDestination {
        override public func getScreen() -> any View {
            DateFormatScreen()
        }
    }
}

// MARK: - UI

/// Inspiration: https://nsdateformatter.com
public struct DateFormatScreen: View {
    public init() {}

    public var body: some View {
        VStack {
            NavigationLink {
                DateFormat1Screen()
            } label: {
                Text(NSLocalizedString("date_format", bundle: .module, comment: ""))
            }

            NavigationLink {
                DateFormat2Screen()
            } label: {
                Text(NSLocalizedString("date_format_using_template", bundle: .module, comment: ""))
            }

            NavigationLink {
                DateFormat3Screen()
            } label: {
                Text(NSLocalizedString("date_format_using_style_navigation_title", bundle: .module, comment: ""))
            }
        }
        .buttonStyle(.bordered)
        .navigationTitle(NSLocalizedString("date_format", bundle: .module, comment: ""))
    }
}

struct DateFormatScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DateFormatScreen()
        }
    }
}
