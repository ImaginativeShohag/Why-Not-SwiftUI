//
//  MenuModels.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 16/10/22.
//

import Foundation
import SwiftUI

struct Menu: Identifiable {
    let title: String
    let image: UIImage
    var count: Int = 0
    var isSelected: Bool
    let target: MenuTarget
    let group: MenuGroup
    let color: Color

    var id: String { title }

    static let menuList = [
        // MARK: Home

        Menu(
            title: "Home",
            image: UIImage(systemName: "house")!,
            isSelected: true,
            target: .home,
            group: .home,
            color: Color.blue
        ),
        Menu(
            title: "Notifications",
            image: UIImage(systemName: "bell")!,
            isSelected: true,
            target: .notifications,
            group: .home,
            color: Color.blue
        ),

        // MARK: Configurations

        Menu(
            title: "Profile",
            image: UIImage(systemName: "person.crop.circle")!,
            isSelected: true,
            target: .profile,
            group: .configs,
            color: Color.blue
        ),
        Menu(
            title: "Settings",
            image: UIImage(systemName: "gear")!,
            isSelected: true,
            target: .settings,
            group: .configs,
            color: Color.blue
        ),

        // MARK: Product

        Menu(
            title: "Products",
            image: UIImage(systemName: "list.bullet.rectangle.fill")!,
            isSelected: true,
            target: .productList,
            group: .product,
            color: Color.blue
        ),
        Menu(
            title: "Product Details",
            image: UIImage(systemName: "list.bullet.below.rectangle")!,
            isSelected: true,
            target: .productDetails,
            group: .product,
            color: Color.blue
        ),
        Menu(
            title: "Cart",
            image: UIImage(systemName: "cart")!,
            isSelected: true,
            target: .cart,
            group: .product,
            color: Color.blue
        ),
    ]
}

enum MenuGroup {
    case home
    case product
    case configs
}

enum MenuTarget {
    // MARK: Home

    case home
    case notifications

    // MARK: Configurations

    case profile
    case settings

    // MARK: Product

    case productList
    case productDetails
    case cart
}
