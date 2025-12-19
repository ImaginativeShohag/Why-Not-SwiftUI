//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import LocalizeKit
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
            HomeScreen()
                .tag(TabItem.home)
                .tabItem {
                    Label(
                        "store_tab_home".localize(default: "Home", comment: "Tab bar label for home"),
                        systemImage: "text.rectangle.page.fill"
                    )
                }
                .accessibilityIdentifier("home_tab")

            CategoriesScreen()
                .tag(TabItem.categories)
                .tabItem {
                    Label(
                        "store_tab_categories".localize(default: "Categories", comment: "Tab bar label for categories"),
                        systemImage: "shippingbox"
                    )
                }
                .accessibilityIdentifier("categories_tab")

            CartScreen()
                .tag(TabItem.bag)
                .tabItem {
                    Label(
                        "store_tab_bag".localize(default: "Bag", comment: "Tab bar label for shopping bag"),
                        systemImage: "bag"
                    )
                }
                .accessibilityIdentifier("bag_tab")
        }
        .tabViewStyle(.automatic)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onLanguageChange()
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        MainScreen()
    }
}

#endif
