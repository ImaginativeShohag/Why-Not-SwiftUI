//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct SideBarOverlay<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if isPresented {
                    SideBarWrapper(
                        showSideBar: $isPresented,
                        content: content
                    )
                    .transition(.move(edge: isPresented ? .leading : .trailing))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.black.opacity(isPresented ? 0.70 : 0))
            .animation(.easeInOut(duration: 0.5), value: isPresented)
            .onTapGesture {
                withAnimation {
                    isPresented = false
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        withAnimation {
                            isPresented = false
                        }
                    }
            )
        }
    }
}

@MainActor
private struct SideBarWrapper<Content: View>: View {
    @Binding var showSideBar: Bool
    let content: () -> Content
    
    init(
        showSideBar: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._showSideBar = showSideBar
        self.content = content
    }
    
    @State private var sideBarWidth = UIScreen.main.bounds.width / 3 + 44
    @State private var x: CGFloat = 0
    
    private var edges = UIApplication.shared.keyWindow?.safeAreaInsets

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                NavigationView {
                    VStack(alignment: .leading, spacing: 0) {
                        content()
                    }
                    .ignoresSafeArea(.container, edges: .all)
                }
                .navigationViewStyle(.stack)
                .padding(.top, edges!.top == 0 ? 15 : edges?.top)
                .padding(.bottom, edges!.bottom == 0 ? 15 : edges?.bottom)
                .frame(width: sideBarWidth)
                .frame(height: UIScreen.main.bounds.height)
                .background(Color.white)
                .ignoresSafeArea(.all, edges: .vertical)
                
                // For right side shadow
                Spacer(minLength: 0)
            }
            .shadow(color: Color.black.opacity(x != 0 ? 0.1 : 0), radius: 5, x: 5, y: 0)
            .offset(x: x)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation {
                        if value.translation.width > 0 {
                            // disabling over drag
                            if x < 0 {
                                let widthCal = sideBarWidth
                                x = -widthCal + value.translation.width
                            }
                        } else {
                            x = value.translation.width
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation {
                        // checking if half the value of menu is dragged
                        let widthCal = sideBarWidth
                        if -x < widthCal / 1.5 {
                            x = 0
                        } else {
                            x = -widthCal
                            showSideBar = false
                        }
                    }
                }
        )
    }
}
