//
//  DynamicTypeScreen.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 23/09/2023.
//

import SwiftUI

// TODO: https://www.hackingwithswift.com/quick-start/swiftui/how-to-specify-the-dynamic-type-sizes-a-view-supports

struct DynamicTypeScreen: View {
    var body: some View {
        DynamicLayout()
    }
}

struct DynamicTypeScreen_Previews: PreviewProvider {
    static var previews: some View {
        DynamicTypeScreen()
    }
}

/// Layout will be changed based on the Dynamic Type size.
struct DynamicLayout: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        /// Layout will be `VStack` if current dynamic type is greater then `XXX Large`.
        /// Means, for `AX1, AX2, AX3, AX4, AX5`, the layout will be `VStack`.
        /// Otherwise it will be `HStack`.
        let layout = dynamicTypeSize > .xxxLarge ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())

        layout {
            Text("Lorem ipsum")
                .frame(maxWidth: .infinity)
            Text("dolor sit")
                .frame(maxWidth: .infinity)
        }
    }
}
