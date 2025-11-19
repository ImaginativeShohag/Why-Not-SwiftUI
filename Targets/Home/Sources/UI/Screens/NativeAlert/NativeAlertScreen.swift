//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CommonUI
import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class NativeAlert: BaseDestination {
        override public func getScreen() -> any View {
            NativeAlertScreen()
        }
    }
}

// MARK: - UI

public struct NativeAlertScreen: View {
    @State var showAlert = false
    @State var alertData: NativeAlertData? = nil
    @State var alertType: NativeAlertScreenAlert? = nil

    public init() {}

    public var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // MARK: - Variation 1

            VStack {
                Text("Variation 1")
                    .font(.system(.title))

                Button {
                    showAlert = true
                } label: {
                    Text(NSLocalizedString("show_alert_button_title", bundle: .module, comment: ""))
                }
            }

            // MARK: - Variation 2

            VStack {
                Text(NSLocalizedString("native_alert_screen_show_alert_button_variation_2", bundle: .module, comment: ""))
                    .font(.system(.title))

                Button {
                    alertData = NativeAlertData(
                        title: "You can do it!",
                        primaryButtonText: "Agreed!"
                    )
                } label: {
                    Text(NSLocalizedString("show_alert_button_title", bundle: .module, comment: ""))
                }
            }

            // MARK: - Variation 3

            VStack {
                Text(NSLocalizedString("delete_alert_button_title", bundle: .module, comment: ""))
                    .font(.system(.title))

                Button {
                    alertType = NativeAlertScreenAlert(id: .create)
                } label: {
                    Text(NSLocalizedString("create_alert_button_title", bundle: .module, comment: ""))
                }

                Button {
                    alertType = NativeAlertScreenAlert(id: .delete)
                } label: {
                    Text(NSLocalizedString("delete_alert_button_title", bundle: .module, comment: ""))
                }

                Button {
                    alertType = NativeAlertScreenAlert(id: .success)
                } label: {
                    Text(NSLocalizedString("success_alert_button_title", bundle: .module, comment: ""))
                }
            }

            Spacer()
        }
        .buttonStyle(.bordered)
        .alert(
            isPresented: $showAlert,
            title: "Select Color",
            message: "Select a color.",
            primaryButtonText: NSLocalizedString("tab_item_label_green", bundle: .module, comment: ""),
            primaryButtonTextColor: Color(.systemGreen),
            primaryButtonHandler: {
                //
            },
            secondaryButtonText: "Red",
            secondaryButtonTextColor: Color(.systemRed),
            secondaryButtonHandler: {
                //
            }
        )
        .alert(data: $alertData)
        .alert(data: $alertType) { item in
            switch item.id {
            case .create:
                return NativeAlertData(
                    title: "Create?",
                    primaryButtonText: "Yes",
                    primaryButtonStyle: .default,
                    secondaryButtonText: NSLocalizedString("cancel_button_title", bundle: .module, comment: ""),
                    secondaryButtonStyle: .cancel
                )
            case .delete:
                return NativeAlertData(
                    title: "Delete?",
                    primaryButtonText: "Yes",
                    primaryButtonStyle: .destructive,
                    secondaryButtonText: NSLocalizedString("cancel_button_title", bundle: .module, comment: ""),
                    secondaryButtonStyle: .cancel
                )
            case .success:
                return NativeAlertData(
                    title: "Success!",
                    primaryButtonText: "Ok"
                )
            }
        }
        .navigationTitle("Native Alert")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NativeAlertScreen_Previews: PreviewProvider {
    static var previews: some View {
        NativeAlertScreen()
    }
}

// MARK: - Models

struct NativeAlertScreenAlert: Identifiable {
    enum AlertType {
        case create
        case delete
        case success
    }

    let id: AlertType
}
