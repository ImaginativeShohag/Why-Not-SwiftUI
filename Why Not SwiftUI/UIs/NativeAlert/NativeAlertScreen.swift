//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct NativeAlertScreenAlert: Identifiable {
    enum AlertType {
        case create
        case delete
        case success
    }

    let id: AlertType
}

struct NativeAlertScreen: View {
    @State var showAlert = false
    @State var alertData: NativeAlertData? = nil
    @State var alertType: NativeAlertScreenAlert? = nil

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // MARK: - Variation 1

            VStack {
                Text("Variation 1")
                    .font(.system(.title))

                Button {
                    showAlert = true
                } label: {
                    Text("Show Alert")
                }
            }

            // MARK: - Variation 2

            VStack {
                Text("Variation 2")
                    .font(.system(.title))

                Button {
                    alertData = NativeAlertData(
                        title: "You can do it!",
                        primaryButtonText: "Agreed!"
                    )
                } label: {
                    Text("Show Alert")
                }
            }

            // MARK: - Variation 3

            VStack {
                Text("Variation 3")
                    .font(.system(.title))

                Button {
                    alertType = NativeAlertScreenAlert(id: .create)
                } label: {
                    Text("Create Alert")
                }

                Button {
                    alertType = NativeAlertScreenAlert(id: .delete)
                } label: {
                    Text("Delete Alert")
                }

                Button {
                    alertType = NativeAlertScreenAlert(id: .success)
                } label: {
                    Text("Success Alert")
                }
            }

            Spacer()
        }
        .buttonStyle(.bordered)
        .alert(
            isPresented: $showAlert,
            title: "Select Color",
            message: "Select a color.",
            primaryButtonText: "Green",
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
                    secondaryButtonText: "Cancel",
                    secondaryButtonStyle: .cancel
                )
            case .delete:
                return NativeAlertData(
                    title: "Delete?",
                    primaryButtonText: "Yes",
                    primaryButtonStyle: .destructive,
                    secondaryButtonText: "Cancel",
                    secondaryButtonStyle: .cancel
                )
            case .success:
                return NativeAlertData(
                    title: "Success!",
                    primaryButtonText: "Ok"
                )
            }
        }
    }
}

struct NativeAlertScreen_Previews: PreviewProvider {
    static var previews: some View {
        NativeAlertScreen()
    }
}
