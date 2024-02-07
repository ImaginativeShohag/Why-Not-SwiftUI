//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI

public extension HomeDestination {
    @ViewBuilder
    static func getScreen(for destination: HomeDestination) -> some View {
        switch destination {
            case is Destination.Typography:
                TextPreviewScreen()
            
            case is Destination.RingChartOverview:
                OverviewRingCardScreen()
            
            case is Destination.RingChartFitness:
                FitnessRingCardScreen()
            
            case is Destination.MediaCaptureAndSelect:
                MediaSelectScreen()
            
            case is Destination.BottomNavAndSideBar:
                BottomNavVsSideBarScreen()
            
            case is Destination.MetricKit:
                MetricKitScreen()
            
            case is Destination.SuperToast:
                SuperToastScreen()
            
            case is Destination.NativeAlert:
                NativeAlertScreen()
            
            case is Destination.SuperProgress:
                SuperProgressScreen()
            
            case is Destination.TextFieldValidation:
                TextFieldValidationScreen()
            
            case is Destination.Accessibility:
                AccessibilityScreen()
            
            case is Destination.LabelToggle:
                LabelToggleScreen()
            
            case is Destination.DateFormat:
                DateFormatScreen()
            
            case is Destination.ReorderList:
                ReorderListScreen()
            
            case is Destination.AlwaysPopover:
                AlwaysPopoverScreen()
            
            default:
                EmptyView()
        }
    }
}
