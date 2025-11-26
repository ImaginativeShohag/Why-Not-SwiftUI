//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class Main: BaseDestination {
        override public func getScreen() -> any View {
            MainScreen()
        }
    }
}

// MARK: - UI

enum TabItem: String {
    case home
    case categories
    case bag
    
    func title() -> String {
        rawValue.capitalized
    }
}

struct MainScreen: View {
    @State var selection: TabItem = .home
    
    var body: some View {
        TabView(selection: $selection) {
            Tab(
                "Home",
                systemImage: "text.rectangle.page.fill",
                value: .home)
            {
                HomeScreen()
            }

            Tab(
                "Categories",
                systemImage: "shippingbox",
                value: .categories)
            {
                CategoriesScreen()
            }
                    
            Tab(
                "Bag",
                systemImage: "bag",
                value: .bag)
            {
                CartScreen()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        MainScreen()
    }
}

#endif
