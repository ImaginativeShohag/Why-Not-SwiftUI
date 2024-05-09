//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI

struct Screen: Identifiable {
    let id = UUID().uuidString
    let name: String
    let destination: BaseDestination

    static let screens: [Screen] = [
        Screen(
            name: "Typography",
            destination: Destination.Typography()
        ),
        Screen(
            name: "Ring Chart: Overview",
            destination: Destination.RingChartOverview()
        ),
        Screen(
            name: "Ring Chart: Fitness",
            destination: Destination.RingChartFitness()
        ),
        Screen(
            name: "Media Capture & Select",
            destination: Destination.MediaCaptureAndSelect()
        ),
        Screen(
            name: "BottomNav vs SideBar",
            destination: Destination.BottomNavAndSideBar()
        ),
        Screen(
            name: "MetricKit",
            destination: Destination.MetricKit()
        ),
        Screen(
            name: "Super Toast",
            destination: Destination.SuperToast()
        ),
        Screen(
            name: "Native Alert",
            destination: Destination.NativeAlert()
        ),
        Screen(
            name: "Super Progress",
            destination: Destination.SuperProgress()
        ),
        Screen(
            name: "TextField Validation",
            destination: Destination.TextFieldValidation()
        ),
        Screen(
            name: "Accessibility",
            destination: Destination.Accessibility()
        ),
        Screen(
            name: "Label Toggle",
            destination: Destination.LabelToggle()
        ),
        Screen(
            name: "Date Format",
            destination: Destination.DateFormat()
        ),
        Screen(
            name: "Reorder List",
            destination: Destination.ReorderList()
        ),
        Screen(
            name: "Always Popover",
            destination: Destination.AlwaysPopover()
        ),
        Screen(
            name: "ShimmerUI",
            destination: Destination.ShimmerUI()
        ),
    ].sorted(by: \.name)
}
