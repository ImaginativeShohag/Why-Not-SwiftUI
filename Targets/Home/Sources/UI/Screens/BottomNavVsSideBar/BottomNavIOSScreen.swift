//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct BottomNavIOSScreen: View {
    let onDismissClicked: ()->Void
    
    @State private var selectedTab: Int = 1

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                ColorScreen(color: .red)
                    .edgesIgnoringSafeArea(.top)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text(NSLocalizedString("tab_item_label_red", bundle: .module, comment: ""))
                    }
                    .tag(1)
                
                ColorScreen(color: .green)
                    .edgesIgnoringSafeArea(.top)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text(NSLocalizedString("tab_item_label_green", bundle: .module, comment: ""))
                    }
                    .tag(2)
                
                ColorScreen(color: .blue)
                    .edgesIgnoringSafeArea(.top)
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text(NSLocalizedString("tab_item_label_blue", bundle: .module, comment: ""))
                    }
                    .tag(3)
                
                ColorScreen(color: .purple)
                    .edgesIgnoringSafeArea(.top)
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text(NSLocalizedString("tab_item_label_purple", bundle: .module, comment: ""))
                    }
                    .tag(4)
            }
            .accentColor(getColor())
            .toolbar {
                ToolbarItem {
                    Button {
                        onDismissClicked()
                    } label: {
                        Text(NSLocalizedString("tab_title_red", bundle: .module, comment: ""))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private func getColor() -> Color {
        switch selectedTab {
            case 1:
                return .red
            case 2:
                return .green
            case 3:
                return .blue
            default:
                return .purple
        }
    }
}

struct BottomNavIOSScreen_Previews: PreviewProvider {
    static var previews: some View {
        BottomNavIOSScreen() {}
            .previewDevice("iPhone 14 Pro Max")
    }
}
