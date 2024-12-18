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
                Text("Date Format")
            }

            NavigationLink {
                DateFormat2Screen()
            } label: {
                Text("Date Format using Template")
            }

            NavigationLink {
                DateFormat3Screen()
            } label: {
                Text("Date Format using Style")
            }
        }
        .buttonStyle(.bordered)
        .navigationTitle("Date Format")
    }
}

struct DateFormatScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DateFormatScreen()
        }
    }
}
