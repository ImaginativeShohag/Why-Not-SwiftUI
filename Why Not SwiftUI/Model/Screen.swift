//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct Screen: Identifiable {
    let id = UUID().uuidString
    let name: String
    let showTitle: Bool
    let destination: AnyView

    static let screens: [Screen] = [
        Screen(name: "Typography", showTitle: true, destination: AnyView(TextPreviewScreen())),
        Screen(name: "Ring Chart: Overview", showTitle: true, destination: AnyView(OverviewRingCardScreen())),
        Screen(name: "Ring Chart: Fitness", showTitle: true, destination: AnyView(FitnessRingCardScreen())),
        Screen(name: "Media Capture & Select", showTitle: true, destination: AnyView(MediaSelectScreen())),
        Screen(name: "BottomNav vs SideBar", showTitle: false, destination: AnyView(BottomNavVsSideBarScreen())),
        Screen(name: "MetricKit", showTitle: true, destination: AnyView(MetricKitScreen())),
        Screen(name: "Cool Toast", showTitle: true, destination: AnyView(CoolToastScreen())),
        Screen(name: "Native Alert", showTitle: true, destination: AnyView(NativeAlertScreen())),
        Screen(name: "Cool Progress", showTitle: true, destination: AnyView(CoolProgressScreen())),
        Screen(name: "TextField Validation", showTitle: true, destination: AnyView(TextFieldValidationScreen())),
        Screen(name: "Accessibility", showTitle: true, destination: AnyView(AccessibilityScreen())),
        Screen(name: "Label Toggle", showTitle: true, destination: AnyView(LabelToggleScreen())),
        Screen(name: "Date Format", showTitle: true, destination: AnyView(DateFormatScreen())),
    ].sorted(by: \.name)
}
