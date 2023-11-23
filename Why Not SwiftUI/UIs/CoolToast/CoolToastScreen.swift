//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct CoolToastScreen: View {
    @State var showToastOne = false
    @State var showToastTwo: CoolToastData? = nil

    @State private var showToast1 = false
    @State private var showToast2 = false
    @State private var showToast3: CoolToastData? = nil

    var body: some View {
        VStack {
            Group {
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
            }

            Spacer().frame(height: 32)

            Group {
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
                    showToastTwo = nil
                } label: {
                    Text("Toast Type Two: Hide")
                }
            }

            Spacer().frame(height: 32)

            Button {
                showToast1.toggle()
            } label: {
                Text("Show Toast 1")
            }

            Button {
                showToast2.toggle()
            } label: {
                Text("Show Toast 2")
            }

            Button {
                if showToast3 == nil {
                    showToast3 = CoolToastData(
                        icon: "flame",
                        iconColor: .systemRed,
                        message: "Impressive!",
                        anchor: .top,
                        duration: 3
                    )
                } else {
                    showToast3 = nil
                }
            } label: {
                Text("Show Toast 3.1")
            }

            Button {
                if showToast3 == nil {
                    showToast3 = CoolToastData(
                        icon: "flame.fill",
                        iconColor: .systemPink,
                        message: "Super Impressive!",
                        anchor: .bottom,
                        duration: 3
                    )
                } else {
                    showToast3 = nil
                }
            } label: {
                Text("Show Toast 3.2")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGroupedBackground)
        .buttonStyle(.bordered)
        .coolToast(
            isPresented: $showToastOne,
            icon: "light.beacon.max.fill",
            message: "Please Be Warn!",
            padding: 32
        )
        .coolToast(
            data: $showToastTwo,
            padding: 120
        )
        .coolToast(
            isPresented: $showToast1,
            icon: "light.beacon.max.fill",
            message: "Please Be Warn!",
            anchor: .top,
            duration: 3,
            padding: 32
        )
        .coolToast(
            isPresented: $showToast2,
            data: CoolToastData(
                icon: "atom",
                iconColor: .systemCyan,
                message: "Awesome!",
                anchor: .top,
                duration: .infinity
            ),
            padding: 120
        )
        .coolToast(
            data: $showToast3,
            padding: 200
        )
        .navigationTitle("Cool Toast")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CoolToastScreen_Previews: PreviewProvider {
    static var previews: some View {
        CoolToastScreen()
    }
}
