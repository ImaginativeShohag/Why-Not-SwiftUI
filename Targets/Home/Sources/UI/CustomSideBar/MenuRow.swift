//
//  MenuRow.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 16/10/22.
//

import SwiftUI

struct MenuItemTitleView: View {
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

struct MenuSubItemView: View {
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
        .onChange(of: isPressed) {
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
