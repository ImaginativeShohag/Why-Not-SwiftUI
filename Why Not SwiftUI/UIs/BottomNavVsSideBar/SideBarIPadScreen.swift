//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct SideBarIPadScreen: View {
    let onDismissClicked: ()->Void
    
    @State var selection = 1

    var body: some View {
        NavigationView {
            // MARK: List

            VStack(spacing: 0) {
                SideBarIPadListItem(
                    title: "Red",
                    systemImage: "house.fill",
                    color: .red,
                    isSelected: selection == 1
                ) {
                    selection = 1
                }

                SideBarIPadListItem(
                    title: "Green",
                    systemImage: "calendar",
                    color: .green,
                    isSelected: selection == 2
                ) {
                    selection = 2
                }

                SideBarIPadListItem(
                    title: "Blue",
                    systemImage: "magnifyingglass",
                    color: .blue,
                    isSelected: selection == 3
                ) {
                    selection = 3
                }

                SideBarIPadListItem(
                    title: "Purple",
                    systemImage: "bell.fill",
                    color: .purple,
                    isSelected: selection == 4
                ) {
                    selection = 4
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .navigationTitle("Awesome")

            // MARK: Details

            ZStack {
                switch selection {
                    case 1:
                        ColorScreen(color: .red)
                            .navigationTitle("Red")
                            .edgesIgnoringSafeArea(.top)
                        
                    case 2:
                        ColorScreen(color: .green)
                            .navigationTitle("Green")
                            .edgesIgnoringSafeArea(.top)
                        
                    case 3:
                        ColorScreen(color: .blue)
                            .navigationTitle("Blue")
                            .edgesIgnoringSafeArea(.top)
                        
                    default:
                        ColorScreen(color: .purple)
                            .navigationTitle("Purple")
                            .edgesIgnoringSafeArea(.top)
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        onDismissClicked()
                    } label: {
                        Text("Back")
                    }
                }
            }
        }
        .accentColor(.white)
    }
}

struct SideBarIPadListItem: View {
    let title: String
    let systemImage: String
    let color: Color
    let isSelected: Bool
    let onClick: () -> Void

    var body: some View {
        Button {
            onClick()
        } label: {
            HStack {
                Image(systemName: systemImage)
                Text(title)
                Spacer()
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(10)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(isSelected ? 1 : 0))
            }
        }
    }
}

extension UISplitViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Force hide sidebar in iPad landscape view
        self.preferredDisplayMode = .secondaryOnly
        self.preferredSplitBehavior = .overlay
    }
}

struct SideBarIPadScreen_Previews: PreviewProvider {
    static var previews: some View {
        SideBarIPadScreen() {}
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")

        SideBarIPadScreen() {}
            .previewInterfaceOrientation(.landscapeLeft)
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
    }
}
