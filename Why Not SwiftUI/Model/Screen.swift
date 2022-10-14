//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct Screen: Identifiable {
    let id = UUID().uuidString
    let name: String
    let destination: AnyView

    static let screens: [Screen] = [
        Screen(name: "Overview Ring Chart", destination: AnyView(OverviewRingCardView())),
        Screen(name: "Fitness Ring Chart", destination: AnyView(FitnessRingCardView())),
        Screen(name: "ImageViewCapturer Example", destination: AnyView(ImageVideoCapturerExampleScreen())),
        Screen(name: "BottomNav vs SideBar", destination: AnyView(BottomNavVsSideBarScreen())),
    ]
}
