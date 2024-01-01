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
