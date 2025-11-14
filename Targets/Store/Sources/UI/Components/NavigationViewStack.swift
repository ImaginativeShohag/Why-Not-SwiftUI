//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct NavigationViewStack<Content: View>: View {
    let content: () -> Content

    var body: some View {
        NavigationView {
            content()
        }
        .navigationViewStyle(.stack)
    }
}
