//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct SideBar: View {
    @Binding var isPresented: Bool
    @Binding var menuList: [Menu]
    var onMenuClicked: (_ menu: MenuTarget) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if isPresented {
                    SideMenuIPad(
                        x: 0,
                        showMenu: $isPresented,
                        menuList: $menuList,
                        onMenuClicked: onMenuClicked
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

struct SideMenuIPad: View {
    init(
        x: CGFloat,
        showMenu: Binding<Bool>,
        menuList: Binding<[Menu]>,
        onMenuClicked: @escaping (MenuTarget) -> Void
    ) {
        self.x = x
        self._showMenu = showMenu
        self._menuList = menuList
        self.onMenuClicked = onMenuClicked
    }
    
    private var edges = UIApplication.shared.keyWindow?.safeAreaInsets
    
    @State private var sideBarWidth = UIScreen.main.bounds.width / 3 + 44
    // to hide view
    @State var x = -UIScreen.main.bounds.width + 90
    
    @State private var isReplenishmentSelected: Bool = false
    @State private var isHealthEssentialSelected: Bool = false
    @State private var isMerchandisingSelected: Bool = false
    
    @Binding var showMenu: Bool
    @Binding var menuList: [Menu]
    
    var onMenuClicked: (_ menu: MenuTarget) -> Void

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    Spacer().frame(height: 60)
                    
                    Button {
                        showMenu = false
                    } label: {
                        HStack {
                            Image(systemName: "star")
                                .frame(width: 42, height: 42)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 21)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .frame(width: 42, height: 42)
                                .cornerRadius(21)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Md. Mahmudul Hasan Shohag")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color.black)
                                
                                Text("Software Engineer")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                    .padding(.bottom, 21)

                    ScrollView(showsIndicators: false) {
                        // MARK: - Home
                        
                        MenuSubItemView(
                            menuList: $menuList,
                            type: .home,
                            showMenu: $showMenu,
                            rowSelectedAction: onMenuClicked
                        )
                        
                        Divider()
                        
                        Group {
                            MenuSubItemView(
                                menuList: $menuList,
                                type: .ar,
                                showMenu: $showMenu,
                                rowSelectedAction: onMenuClicked
                            )

                            // MARK: - Health Essential

                            MenuItemTitleView(
                                title: "Health Essential",
                                icon: UIImage(systemName: "house")!,
                                iconTint: Color.blue,
                                isSelected: $isHealthEssentialSelected
                            ) {
                                withAnimation {
                                    isHealthEssentialSelected.toggle()
                                }
                            }
                           
                            if isHealthEssentialSelected {
                                MenuSubItemView(
                                    menuList: $menuList,
                                    type: .healthEssential,
                                    showMenu: $showMenu,
                                    rowSelectedAction: onMenuClicked
                                )
                                .padding(.leading, 32)
                            }
                        
                            // MARK: - Merchandising Element

                            MenuItemTitleView(
                                title: "Merchandising Elements",
                                icon: UIImage(systemName: "briefcase.fill")!,
                                iconTint: Color.green,
                                isSelected: $isMerchandisingSelected
                            ) {
                                withAnimation {
                                    isMerchandisingSelected.toggle()
                                }
                            }
                               
                            if isMerchandisingSelected {
                                MenuSubItemView(
                                    menuList: $menuList,
                                    type: .merchandising,
                                    showMenu: $showMenu,
                                    rowSelectedAction: onMenuClicked
                                )
                                .padding(.leading, 32)
                            }
                        }
                        
                        // MARK: - Replenishment

                        MenuItemTitleView(
                            title: "Replenishment",
                            icon: UIImage(systemName: "arrow.3.trianglepath")!,
                            iconTint: Color.orange,
                            isSelected: $isReplenishmentSelected
                        ) {
                            withAnimation {
                                isReplenishmentSelected.toggle()
                            }
                        }
                        
                        if isReplenishmentSelected {
                            MenuSubItemView(
                                menuList: $menuList,
                                type: .replenishment,
                                showMenu: $showMenu,
                                rowSelectedAction: onMenuClicked
                            )
                            .padding(.leading, 32)
                        }
                        
                        MenuSubItemView(
                            menuList: $menuList,
                            type: .scanner,
                            showMenu: $showMenu,
                            rowSelectedAction: onMenuClicked
                        )
                        
                        Divider()
                        
                        // MARK: - Others
                        
                        MenuSubItemView(
                            menuList: $menuList,
                            type: .other,
                            showMenu: $showMenu,
                            rowSelectedAction: onMenuClicked
                        )
                        
                        Spacer(minLength: 72)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            //
                        } label: {
                            HStack {
                                Spacer()
                                Text("Sign out")
                                    .font(.system(size: 17))
                                    .foregroundColor(Color.red)
                                Spacer()
                            }
                            .frame(height: 44)
                            .background(Color("signout_btn_color"))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, edges!.top == 0 ? 15 : edges?.top)
                .padding(.bottom, edges!.bottom == 0 ? 15 : edges?.bottom)
                .frame(width: sideBarWidth)
                .frame(height: UIScreen.main.bounds.height)
                .background(Color.white)
                .ignoresSafeArea(.all, edges: .vertical)
                .onAppear {
                    guard let currentSelectedMenu = menuList.first(where: { $0.isSelected == true }) else {
                        return
                    }
                    
                    if currentSelectedMenu.group == .replenishment {
                        isReplenishmentSelected = true
                    } else if currentSelectedMenu.group == .healthEssential {
                        isHealthEssentialSelected = true
                    } else if currentSelectedMenu.group == .merchandising {
                        isMerchandisingSelected = true
                    }
                }
                
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
                            showMenu = false
                        }
                    }
                }
        )
    }
}

// MARK: - View components

private struct MenuItemTitleView: View {
    let title: String
    let icon: UIImage
    let iconTint: Color
    @Binding var isSelected: Bool
    let callback: () -> Void
    
    var body: some View {
        Button {
            callback()
        } label: {
            HStack {
                Image(uiImage: icon)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(iconTint)
                    .frame(width: 22, height: 22)
                
                Text(title)
                    .font(.system(size: 17))
                    .padding(.horizontal, 13)
                    .lineLimit(1)
                    .foregroundColor(Color.black)
                Spacer()
                Image(systemName: isSelected ? "chevron.down" : "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .foregroundColor(Color.black)
            }
            .frame(height: 44)
            .padding(.horizontal, 10)
        }
    }
}

private struct MenuSubItemView: View {
    @Binding var menuList: [Menu]
    let type: MenuGroup
    @Binding var showMenu: Bool
    var rowSelectedAction: (_ menu: MenuTarget) -> Void
    
    var body: some View {
        LazyVStack {
            ForEach(menuList.filter { $0.group == type }) { menu in
                MenuRow(
                    image: menu.image,
                    title: menu.title,
                    counter: (menu.title == "Bag") ? 5 : (menu.title == "Notifications" ? 10 : 0),
                    isSelected: menu.isSelected,
                    color: menu.color
                ) {
                    for count in 0 ..< menuList.count {
                        if menuList[count].target == menu.target {
                            menuList[count].isSelected = true
                        } else {
                            menuList[count].isSelected = false
                        }
                    }
                            
                    showMenu = false
                            
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        rowSelectedAction(menu.target)
                    }
                }
            }
        }
    }
}

struct SidebarMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

private struct MenuRow: View {
    var image: UIImage
    var title: String
    var counter: Int
    var isSelected: Bool
    var color: Color
    var onClick: () -> Void
    
    @State private var isPressed: Bool = false
    @State private var textColor: Color = .clear
    
    var body: some View {
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { _ in
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    isPressed = true
                }
            }
            .onEnded { _ in
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    isPressed = false
                }
            }
        
        Button {
            onClick()
        } label: {
            VStack {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(isPressed ? .white : (isSelected ? .white : color))
                        .frame(width: 22, height: 22)
                
                    Text(title)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .colorMultiply(textColor)
                        .padding(.horizontal, 13)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    if counter > 0 {
                        Text("\(counter)")
                            .foregroundColor(.white)
                            .colorMultiply(textColor)
                            .font(Font.system(size: 17))
                    }
                }
                .frame(height: 44)
                .padding(.horizontal, 10)
            }
            .background(isPressed ? color : (isSelected ? color : Color.white))
            .frame(maxWidth: .infinity, maxHeight: 44)
            .cornerRadius(10)
        }
        .simultaneousGesture(dragGesture)
        .buttonStyle(SidebarMenuButtonStyle())
        .onAppear {
            textColor = isPressed ? .white : (isSelected ? .white : Color.black)
        }
        .onChange(of: isPressed) { isPressed in
            withAnimation(Animation.easeInOut(duration: 0.2)) {
                textColor = isPressed ? .white : (isSelected ? .white : Color.black)
            }
        }
    }
}

struct MenuRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MenuRow(
                image: UIImage(systemName: "star")!,
                title: "Lorem Ipsum",
                counter: 0,
                isSelected: false,
                color: .red
            ) {}
            
            MenuRow(
                image: UIImage(systemName: "star")!,
                title: "Lorem Ipsum",
                counter: 5,
                isSelected: true,
                color: .red
            ) {}
            
            MenuRow(
                image: UIImage(systemName: "star")!,
                title: "Lorem Ipsum",
                counter: 5,
                isSelected: false,
                color: .red
            ) {}
        }
    }
}

// MARK: - Menu Models

struct Menu: Identifiable {
    let title: String
    let image: UIImage
    var count: Int = 0
    var isSelected: Bool
    let target: MenuTarget
    let group: MenuGroup
    let color: Color
    
    var id: String { title }
    
    static var menuList = [
        // MARK: - Home

        Menu(
            title: "Home",
            image: UIImage(systemName: "house")!,
            isSelected: true,
            target: .MyStore,
            group: .home,
            color: Color.blue
        ),
        Menu(
            title: "AR Scan",
            image: UIImage(systemName: "house")!,
            isSelected: false,
            target: .ARScan,
            group: .ar,
            color: Color.blue
        ),
        Menu(
            title: "NFC",
            image: UIImage(systemName: "sensor.tag.radiowaves.forward")!,
            isSelected: false,
            target: .NFC,
            group: .nfc,
            color: Color.blue
        ),
        Menu(
            title: "Scanner",
            image: UIImage(systemName: "doc.viewfinder")!,
            isSelected: false,
            target: .Inventory,
            group: .scanner,
            color: Color.blue
        ),
        
        // MARK: - Replenishment

        Menu(
            title: "Catalog",
            image: UIImage(systemName: "menucard")!,
            isSelected: false,
            target: .Catalog,
            group: .replenishment,
            color: Color.orange
        ),
        Menu(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass")!,
            isSelected: false,
            target: .RepSearch,
            group: .replenishment,
            color: Color.orange
        ),
        Menu(
            title: "Bag",
            image: UIImage(systemName: "cart.fill")!,
            isSelected: false,
            target: .Bag,
            group: .replenishment,
            color: Color.orange
        ),
        Menu(
            title: "Order",
            image: UIImage(systemName: "shippingbox")!,
            isSelected: false,
            target: .Order,
            group: .replenishment,
            color: Color.orange
        ),
        Menu(
            title: "Alerts",
            image: UIImage(systemName: "bell.badge")!,
            isSelected: false,
            target: .Alert,
            group: .replenishment,
            color: Color.orange
        ),
        
        // MARK: - Health Essential

        Menu(
            title: "Count",
            image: UIImage(systemName: "house")!,
            isSelected: false,
            target: .Count,
            group: .healthEssential,
            color: Color.blue
        ),
        Menu(
            title: "Alerts",
            image: UIImage(systemName: "bell.badge")!,
            isSelected: false,
            target: .HEAlerts,
            group: .healthEssential,
            color: Color.blue
        ),
        Menu(
            title: "Orders",
            image: UIImage(systemName: "shippingbox")!,
            isSelected: false,
            target: .HEOrders,
            group: .healthEssential,
            color: Color.blue
        ),
        
        // MARK: - Merchandising Element

        Menu(
            title: "Products",
            image: UIImage(systemName: "briefcase.fill")!,
            isSelected: false,
            target: .MerProducts,
            group: .merchandising,
            color: Color.green
        ),
        Menu(
            title: "Alerts",
            image: UIImage(systemName: "bell.badge")!,
            isSelected: false,
            target: .MerAlerts,
            group: .merchandising,
            color: Color.green
        ),
        
        // MARK: - Others

        Menu(
            title: "Notifications",
            image: UIImage(systemName: "bell.badge")!,
            isSelected: false,
            target: .Notifications,
            group: .other,
            color: Color.blue
        )
    ]
}

enum MenuGroup {
    case home
    case ar
    case nfc
    case scanner
    case replenishment
    case healthEssential
    case merchandising
    case other
}

enum MenuTarget {
    // MARK: Home

    case MyStore
    case ARScan
    case Inventory
    case NFC
    
    // MARK: Other
    
    case Notifications
    
    // MARK: Replenishment

    case Catalog
    case RepSearch
    case Bag
    case Order
    case Alert
    
    // MARK: Health Essential

    case Count
    case HEAlerts
    case HEOrders
    
    // MARK: Merchandising Elements
    
    case MerProducts
    case MerAlerts
    
    //
    case WebView
    
    case Newsletter
}
