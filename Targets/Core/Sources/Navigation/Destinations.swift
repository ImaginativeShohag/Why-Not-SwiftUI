//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import SwiftUI

/// - Note: The `Destination`s parameters will be ignored when destinations are gets compared.
public enum Destination {
    // MARK: - Screens

    case typography
    case ringChartOverview
    case ringChartFitness
    case mediaCaptureAndSelect
    case bottomNavAndSideBar
    case metricKit
    case superToast
    case nativeAlert
    case superProgress
    case textFieldValidation
    case accessibility
    case labelToggle
    case dateFormat
    case reorderList
    case alwaysPopover

    // MARK: - Pre-defined

    /// This is a special destination for root screen.
    case root

    // MARK: - Only for Unit Testing

    #if DEBUG
        case A
        case B
        case C(id: Int)
    #endif
}

/// We used the `description` to conform to `Hashable` and `Equatable`. It is needed to ignore the parameters of the `Destination`. The `NavController` can check any `Destination` for `popUpTo` or `launchSingleTop` etc. without checking the parameters of the `Destination`.
extension Destination: CustomStringConvertible {
    public var description: String {
        switch self {
            // MARK: - Screens

        case .typography:
            "typography"
        case .ringChartOverview:
            "ringChartOverview"
        case .ringChartFitness:
            "ringChartFitness"
        case .mediaCaptureAndSelect:
            "mediaCaptureAndSelect"
        case .bottomNavAndSideBar:
            "bottomNavAndSideBar"
        case .metricKit:
            "metricKit"
        case .superToast:
            "superToast"
        case .nativeAlert:
            "nativeAlert"
        case .superProgress:
            "superProgress"
        case .textFieldValidation:
            "textFieldValidation"
        case .accessibility:
            "accessibility"
        case .labelToggle:
            "labelToggle"
        case .dateFormat:
            "dateFormat"
        case .reorderList:
            "reorderList"
        case .alwaysPopover:
            "alwaysPopover"

            // MARK: - Pre-defined

        case .root:
            "root"

            // MARK: - Only for Unit Testing

        #if DEBUG
            case .A:
                "A"
            case .B:
                "B"
            case .C:
                "C"
        #endif
        }
    }
}
