//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct NativeAlertScreen: View {
    @State var showAlert = false

    var body: some View {
        ZStack {
            Button {
                showAlert.toggle()
            } label: {
                Text("Show Alert")
            }
        }
        .alert(
            isPresented: $showAlert,
            title: "Awesome title",
            message: "Awesome message",
            primaryButtonText: "Ok",
            primaryButtonTextColor: Color(.systemGreen),
            primaryHandler: {
                //
            },
            secondaryButtonText: "Cool",
            secondaryButtonTextColor: Color(.systemRed),
            secondaryHandler: {
                //
            }
        )
    }
}

struct NativeAlertScreen_Previews: PreviewProvider {
    static var previews: some View {
        NativeAlertScreen()
    }
}
