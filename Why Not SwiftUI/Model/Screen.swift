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
        Screen(name: "Overview Ring Chart", showTitle: true, destination: AnyView(OverviewRingCardView())),
        Screen(name: "Fitness Ring Chart", showTitle: true, destination: AnyView(FitnessRingCardView())),
        Screen(name: "ImageViewCapturer Example", showTitle: true, destination: AnyView(ImageVideoCapturerExampleScreen())),
        Screen(name: "BottomNav vs SideBar", showTitle: false, destination: AnyView(BottomNavVsSideBarScreen())),
        Screen(name: "MetricKit", showTitle: true, destination: AnyView(MetricKitScreen())),
        Screen(name: "Cool Toast", showTitle: true, destination: AnyView(CoolToastScreen())),
    ]
}
