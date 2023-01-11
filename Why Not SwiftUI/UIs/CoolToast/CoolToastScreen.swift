//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct CoolToastScreen: View {
    @State var showToastOne = false
    @State var showToastTwo: CoolToastData = .emptyInstance()

    var body: some View {
        VStack {
            Button {
                showToastOne = true
            } label: {
                Text("Toast Type One: Show")
            }
            
            Button {
                showToastOne = false
            } label: {
                Text("Toast Type One: Hide")
            }
            
            Spacer().frame(height: 32)

            Button {
                showToastTwo = CoolToastData(
                    icon: "flame",
                    iconColor: .systemRed,
                    message: "Impressive!"
                )
            } label: {
                Text("Toast Type Two: Show")
            }
            
            Button {
                showToastTwo = .emptyInstance()
            } label: {
                Text("Toast Type Two: Hide")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGroupedBackground)
        .coolToast(
            isPresented: $showToastOne,
            icon: "light.beacon.max.fill",
            message: "Please Be Warn!",
            paddingBottom: 32
        )
        .coolToast(
            data: $showToastTwo,
            paddingBottom: 120
        )
    }
}

struct CoolToastScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoolToastScreen()
    }
}
