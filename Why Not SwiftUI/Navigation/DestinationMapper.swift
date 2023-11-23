//
//  Copyright © 2023 Apple Inc. All rights reserved.
//

import SwiftUI

enum DestinationMapper {
    @ViewBuilder
    static func getScreen(destination: Destination) -> some View {
        switch destination {
            // MARK: - Only for Unit Testing

            // #if DEBUG
            case .A:
                EmptyView()
            case .B:
                EmptyView()
            case .C:
                EmptyView()
            // #endif
                
            // MARK: - Pre-defined
                
            case .root:
                EmptyView()
                
            // MARK: - Screens
                
            case .navigationControllerDemo:
                NavigationControllerDemoScreen()
            
            case .typography:
                TextPreviewScreen()
            
            case .ringChartOverview:
                OverviewRingCardScreen()
            
            case .ringChartFitness:
                FitnessRingCardScreen()
            
            case .mediaCaptureAndSelect:
                MediaSelectScreen()
            
            case .bottomNavAndSideBar:
                BottomNavVsSideBarScreen()
            
            case .metricKit:
                MetricKitScreen()
            
            case .coolToast:
                CoolToastScreen()
            
            case .nativeAlert:
                NativeAlertScreen()
            
            case .coolProgress:
                CoolProgressScreen()
            
            case .textFieldValidation:
                TextFieldValidationScreen()
            
            case .accessibility:
                AccessibilityScreen()
            
            case .labelToggle:
                LabelToggleScreen()
            
            case .dateFormat:
                DateFormatScreen()
            
            case .reorderList:
                ReorderListScreen()
            
            case .alwaysPopover:
                AlwaysPopoverScreen()
        }
    }
}
