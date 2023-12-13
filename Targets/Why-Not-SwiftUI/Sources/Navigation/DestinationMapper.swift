//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

enum DestinationMapper {
    @ViewBuilder
    static func getScreen(destination: Destination) -> some View {
        switch destination {
            // MARK: - Only for Unit Testing

            #if DEBUG
                case .A:
                    EmptyView()
                case .B:
                    EmptyView()
                case .C:
                    EmptyView()
            #endif
                
            // MARK: - Pre-defined
                
            case .root:
                EmptyView()
                
            // MARK: - Screens
            
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
            
            case .superToast:
                SuperToastScreen()
            
            case .nativeAlert:
                NativeAlertScreen()
            
            case .superProgress:
                SuperProgressScreen()
            
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
