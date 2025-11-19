//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
import News
import SwiftUI
import Todo
import Store

struct Screen: Identifiable, Sendable {
    let id = UUID().uuidString
    let name: String
    let destination: BaseDestination

    static let screens: [Screen] = [
        Screen(
            name: NSLocalizedString("typography_navigation_title", bundle: .module, comment: ""),
            destination: Destination.Typography()
        ),
        Screen(
            name: NSLocalizedString("ring_chart_overview_title", bundle: .module, comment: ""),
            destination: Destination.RingChartOverview()
        ),
        Screen(
            name: NSLocalizedString("ring_chart_fitness", bundle: .module, comment: ""),
            destination: Destination.RingChartFitness()
        ),
        Screen(
            name: NSLocalizedString("media_capture_and_select", bundle: .module, comment: ""),
            destination: Destination.MediaCaptureAndSelect()
        ),
        Screen(
            name: "BottomNav vs SideBar",
            destination: Destination.BottomNavAndSideBar()
        ),
        Screen(
            name: NSLocalizedString("metric_kit_screen_title", bundle: .module, comment: ""),
            destination: Destination.MetricKit()
        ),
        Screen(
            name: NSLocalizedString("super_toast_screen_title", bundle: .module, comment: ""),
            destination: Destination.SuperToast()
        ),
        Screen(
            name: "Native Alert",
            destination: Destination.NativeAlert()
        ),
        Screen(
            name: NSLocalizedString("super_progress", bundle: .module, comment: ""),
            destination: Destination.SuperProgress()
        ),
        Screen(
            name: "TextField Validation",
            destination: Destination.TextFieldValidation()
        ),
        Screen(
            name: NSLocalizedString("accessibility_screen_title", bundle: .module, comment: ""),
            destination: Destination.Accessibility()
        ),
        Screen(
            name: NSLocalizedString("label_toggle", bundle: .module, comment: ""),
            destination: Destination.LabelToggle()
        ),
        Screen(
            name: NSLocalizedString("date_format", bundle: .module, comment: ""),
            destination: Destination.DateFormat()
        ),
        Screen(
            name: NSLocalizedString("reorder_list_screen_title", bundle: .module, comment: ""),
            destination: Destination.ReorderList()
        ),
        Screen(
            name: "Always Popover",
            destination: Destination.AlwaysPopover()
        ),
        Screen(
            name: NSLocalizedString("shimmer_ui_screen_title", bundle: .module, comment: ""),
            destination: Destination.ShimmerUI()
        ),
        Screen(
            name: "📋 Todo App",
            destination: Destination.TodoIntro()
        ),
        Screen(
            name: "🥭 News App",
            destination: Destination.NewsHome()
        ),
        Screen(
            name: "Network: `URLSession` Example",
            destination: Destination.URLSession()
        ),
        Screen(
            name: "Network: `Alamofire` Example",
            destination: Destination.Alamofire()
        ),
        Screen(
            name: "`@AppStorage` Example",
            destination: Destination.AppStorage()
        ),
        Screen(
            name: "`Realm` Example",
            destination: Destination.RealmDB()
        ),
        Screen(
            name: NSLocalizedString("animation_example_navigation_title", bundle: .module, comment: ""),
            destination: Destination.Animation()
        ),
        Screen(
            name: "`WebView` Example",
            destination: Destination.WebView()
        ),
        Screen(
            name: "`Ollama` Example",
            destination: Destination.Ollama()
        ),
        Screen(
            name: "Map Example",
            destination: Destination.Map()
        ),
        Screen(
            name: "🏬 Store Overflow",
            destination: Destination.StoreSplash()
        ),
        Screen(
            name: "`TestUtils` UI Tests Demo",
            destination: Destination.TestUtilsUITestsDemo()
        ),
    ].sorted { old, new in
        old.name.filter { $0.isLetter || $0.isNumber } < new.name.filter { $0.isLetter || $0.isNumber }
    }
}
