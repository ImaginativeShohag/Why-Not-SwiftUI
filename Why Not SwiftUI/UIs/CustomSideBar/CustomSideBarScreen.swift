//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct CustomSideBarScreen: View {
    @State private var showSideBar: Bool = true

    var body: some View {
        NavigationView {
            SideBarLayout(
                showSideBar: $showSideBar,
                sideBar: {
                    SideBarContent()
                },
                content: {
                    Text("Hello, World!")
                }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSideBar.toggle()
                    } label: {
                        Image(systemName: "sidebar.left")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct SideBarContent: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Sidebar")
                Text("Sidebar")
                Text("Sidebar")
            }
        }
        .frame(maxWidth: .infinity)
        .background(.green)
    }
}

struct SideBarLayout<SideBar: View, Content: View>: View {
    @Binding var showSideBar: Bool
    let sideBar: () -> SideBar
    let content: () -> Content

    init(
        showSideBar: Binding<Bool>,
        @ViewBuilder sideBar: @escaping () -> SideBar,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._showSideBar = showSideBar
        self.sideBar = sideBar
        self.content = content
    }

    var body: some View {
        ZStack {
            content()

            SideBarOverlay(
                isPresented: $showSideBar,
                content: sideBar
            )
        }
    }
}

struct CustomSideBarScreen_Previews: PreviewProvider {
    static var previews: some View {
        CustomSideBarScreen()
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
    }
}
