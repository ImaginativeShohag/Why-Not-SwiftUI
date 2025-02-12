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

struct Home: View {
    // MARK: - PROPERTIES

    var safeArea: EdgeInsets
    var size: CGSize
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                /// Album Pic
                ArtWork()
                
                GeometryReader { proxy in
                    /// Since we ignored top edge
                    let minY = proxy.frame(in: .named("SCROLL")).minY - safeArea.top
                    
                    Button(action: {}, label: {
                        Text("SHUFFLE PLAY")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 45)
                            .padding(.vertical, 12)
                            .background {
                                Capsule()
                                    .fill(.green.gradient)
                            }
                    }) //: BUTTON SHUFFLE PLAY
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: minY < 50 ? -(minY - 50) : 0)
                } //: GEOMETRY
                .frame(height: 50)
                .padding(.top, -34)
                .zIndex(1)
                
                VStack {
                    Text("Popular")
                        .fontWeight(.heavy)
                    
                    /// Album View
                    AlbumView()
                } //: VSTACK
                .padding(.top, 10)
                .zIndex(0)
            } //: VSTACK
            .overlay(alignment: .top) {
                HeaderView()
            }
        } //: SCROLL
        .scrollIndicators(.hidden)
        .coordinateSpace(name: "SCROLL")
    }
    
    // MARK: - Views
    
    @ViewBuilder
    private func ArtWork() -> some View {
        let randomListens = Int.random(in: 5_000_000...30_000_000)
        let height = size.height * 0.45
        GeometryReader { proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.8))
            
            Image(systemName: "star")
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0))
                .clipped()
                .overlay {
                    ZStack {
                        /// Gradient Overlay
                        Rectangle()
                            .fill(
                                .linearGradient(colors: [
                                    .black.opacity(0 - progress),
                                    .black.opacity(0.1 - progress),
                                    .black.opacity(0.3 - progress),
                                    .black.opacity(0.5 - progress),
                                    .black.opacity(0.8 - progress),
                                    .black.opacity(1),
                                ], startPoint: .top, endPoint: .bottom)
                            )
                        
                        VStack(spacing: 0) {
                            Text("Mylo Xyloto")
                                .font(.system(size: 45))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("Coldplay")
                                .font(.callout.bold())
                                .padding(.top, 15)
                            
                            Text("\(randomListens) Monthly Listners")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.gray)
                            // .padding(.top, 15)
                        } //: VSTACK
                        .opacity(1 + (progress > 0 ? -progress : progress))
                        /// Moving with ScrollView
                        .padding(.bottom, 55)
                        .offset(y: minY < 0 ? minY : 0)
                    } //: ZSTACK
                } //: Gradient Overlay
                .offset(y: -minY)
        } //: GEOMETRY
        .frame(height: height + safeArea.top)
    }
    
    @ViewBuilder
    private func AlbumView() -> some View {
        VStack(spacing: 25) {
            ForEach(1 ..< 50) { index in
                HStack(spacing: 25) {
                    let randomListens = Int.random(in: 200_000...2_000_000)
                    
                    Text("\(index + 1)")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(index) - Song Title")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        
                        Text("\(randomListens)")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    } //: VSTACK
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.gray)
                }
            } //: LOOP Songs
        } //: VSTACK
        .padding(15)
    }
    
    /// Header View
    @ViewBuilder
    func HeaderView() -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let height = size.height * 0.45
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.8))
            let titleProgress = minY / height
            HStack(spacing: 15) {
                Button(action: {}, label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        /// You could use title progress to apply different styles based on the scroll position
                        .foregroundStyle(-titleProgress < 0.75 ? .white : .blue)
                }) //: Back Button
                
                Spacer(minLength: 0)
                
                Button(action: {}, label: {
                    Text("FOLLOWING")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .overlay(
                            Capsule()
                                .stroke(style: .init(lineWidth: 1))
                                .foregroundStyle(.white)
                        )
                }) //: Follow Button
                .opacity(1 + progress)
                
                Button(action: {}, label: {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundStyle(.white)
                }) //: Back Button
            } //: HSTACK
            .background(Color.green)
            .overlay {
                Text("Coldplay")
                    .fontWeight(.semibold)
                    /// Choose where to display the title
                    .offset(y: -titleProgress > 0.75 ? 0 : 45)
                    .clipped()
                    .animation(.easeInOut(duration: 0.25),
                               value: -titleProgress > 0.75 ? 0 : 45)
            }
            .padding(.top, safeArea.top + 10)
            .background(Color.yellow)
            .padding([.horizontal, .bottom], 15)
            .background(Color.blue)
            .background {
                // Color.black
                Rectangle()
                    /// Apply Material effects here for translucency or similar stuff
                    .fill(Material.ultraThinMaterial)
                    .opacity(-progress > 1 ? 1 : 0)
            }
            .offset(y: -minY)
        } //: GEOMETRY
        .frame(height: 35)
        .background(Color.red)
    }
}

#Preview {
    GeometryReader { proxy in
        let safeArea = proxy.safeAreaInsets
        let size = proxy.size
        Home(safeArea: safeArea, size: size)
            .ignoresSafeArea(.container, edges: [.top])
    }
    .preferredColorScheme(.dark)
}
