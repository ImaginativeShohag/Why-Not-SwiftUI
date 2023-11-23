//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct Screen: Identifiable {
    let id = UUID().uuidString
    let name: String
    let destination: Destination

    static let screens: [Screen] = [
        Screen(
            name: "Typography",
            destination: .typography
        ),
        Screen(
            name: "Ring Chart: Overview",
            destination: .ringChartOverview
        ),
        Screen(
            name: "Ring Chart: Fitness",
            destination: .ringChartFitness
        ),
        Screen(
            name: "Media Capture & Select",
            destination: .mediaCaptureAndSelect
        ),
        Screen(
            name: "BottomNav vs SideBar",
            destination: .bottomNavAndSideBar
        ),
        Screen(
            name: "MetricKit",
            destination: .metricKit
        ),
        Screen(
            name: "Cool Toast",
            destination: .coolToast
        ),
        Screen(
            name: "Native Alert",
            destination: .nativeAlert
        ),
        Screen(
            name: "Cool Progress",
            destination: .coolProgress
        ),
        Screen(
            name: "TextField Validation",
            destination: .textFieldValidation
        ),
        Screen(
            name: "Accessibility",
            destination: .accessibility
        ),
        Screen(
            name: "Label Toggle",
            destination: .labelToggle
        ),
        Screen(
            name: "Date Format",
            destination: .dateFormat
        ),
        Screen(
            name: "Reorder List",
            destination: .reorderList
        ),
        Screen(
            name: "Always Popover",
            destination: .alwaysPopover
        ),
    ].sorted(by: \.name)
}
