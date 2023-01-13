//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct NativeAlertScreenAlert: Identifiable {
    enum AlertType {
        case create
        case success
    }

    let id: AlertType
}

struct NativeAlertScreen: View {
    @State var showAlert = true
    @State var alertData: NativeAlertData? = nil
    @State var alertType: NativeAlertScreenAlert? = nil

    var body: some View {
        VStack {
            Spacer()

            Button {
                showAlert = true
            } label: {
                Text("Show Alert 1")
            }

            Button {
                alertData = NativeAlertData(
                    title: "Alert 2",
                    primaryButtonText: "Ok"
                )
            } label: {
                Text("Show Alert 2")
            }

            Button {
                alertType = NativeAlertScreenAlert(id: .create)
            } label: {
                Text("Show Alert 3: Create")
            }

            Button {
                alertType = NativeAlertScreenAlert(id: .success)
            } label: {
                Text("Show Alert 3: Success")
            }
            Spacer()
        }
        .alert(
            isPresented: $showAlert,
            title: "Awesome title",
            message: "Awesome message",
            primaryButtonText: "Ok",
            primaryButtonTextColor: Color(.systemGreen),
            primaryButtonHandler: {
                //
            },
            secondaryButtonText: "Cool",
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
                    secondaryButtonText: "No"
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
