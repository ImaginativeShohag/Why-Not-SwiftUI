//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CommonUI
import Core
import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class SuperToast: BaseDestination {
        override public func getScreen() -> any View {
            SuperToastScreen()
        }
    }
}

// MARK: - UI

public struct SuperToastScreen: View {
    @State var showToastOne = false
    @State var showToastTwo: SuperToastData? = nil

    @State private var showToast1 = false
    @State private var showToast2 = false
    @State private var showToast3: SuperToastData? = nil

    public init() {}

    public var body: some View {
        VStack {
            Group {
                Button {
                    showToastOne = true
                } label: {
                    Text(NSLocalizedString("show_toast_type_one_button_label", bundle: .module, comment: ""))
                }

                Button {
                    showToastOne = false
                } label: {
                    Text(NSLocalizedString("toast_type_one_hide_button_label", bundle: .module, comment: ""))
                }
            }

            Spacer().frame(height: 32)

            Group {
                Button {
                    showToastTwo = SuperToastData(
                        icon: "flame",
                        iconColor: .systemRed,
                        message: "Impressive!"
                    )
                } label: {
                    Text(NSLocalizedString("toast_type_two_show_button_label", bundle: .module, comment: ""))
                }

                Button {
                    showToastTwo = nil
                } label: {
                    Text(NSLocalizedString("toast_type_two_hide_button_label", bundle: .module, comment: ""))
                }
            }

            Spacer().frame(height: 32)

            Button {
                showToast1.toggle()
            } label: {
                Text(NSLocalizedString("show_toast_1", bundle: .module, comment: ""))
            }

            Button {
                showToast2.toggle()
            } label: {
                Text(NSLocalizedString("show_toast_2_button_label", bundle: .module, comment: ""))
            }

            Button {
                if showToast3 == nil {
                    showToast3 = SuperToastData(
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
                Text(NSLocalizedString("show_toast_3_1_button_label", bundle: .module, comment: ""))
            }

            Button {
                if showToast3 == nil {
                    showToast3 = SuperToastData(
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
                Text(NSLocalizedString("show_toast_3_2_button_label", bundle: .module, comment: ""))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGroupedBackground)
        .buttonStyle(.bordered)
        .superToast(
            isPresented: $showToastOne,
            icon: "light.beacon.max.fill",
            message: "Please Be Warn!",
            padding: 32
        )
        .superToast(
            data: $showToastTwo,
            padding: 120
        )
        .superToast(
            isPresented: $showToast1,
            icon: "light.beacon.max.fill",
            message: "Please Be Warn!",
            anchor: .top,
            duration: 3,
            padding: 32
        )
        .superToast(
            isPresented: $showToast2,
            data: SuperToastData(
                icon: "atom",
                iconColor: .systemCyan,
                message: "Awesome!",
                anchor: .top,
                duration: .infinity
            ),
            padding: 120
        )
        .superToast(
            data: $showToast3,
            padding: 200
        )
        .navigationTitle(NSLocalizedString("toast_type_one_show_button_label", bundle: .module, comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SuperToastScreen_Previews: PreviewProvider {
    static var previews: some View {
        SuperToastScreen()
    }
}
