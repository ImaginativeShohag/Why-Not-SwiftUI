//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

struct CustomTextFieldView: View {
    @Binding var value: String
    var placeHolder: String
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool
    @State private var showValueField = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField(
                "",
                text: $value
            )
            .font(.system(size: 16))
            .focused($isFocused)
            .onSubmit {
                if value == "" {
                    withAnimation(.easeOut) {
                        showValueField = false
                    }
                }
            }
            .keyboardType(keyboardType)
            .onChange(of: isFocused) { focused in
                if focused {
                    withAnimation(.easeIn) {
                        showValueField = true
                    }
                } else {
                    if value == "" {
                        withAnimation(.easeOut) {
                            showValueField = false
                        }
                    }
                }
            }
            .onChange(of: value) { newValue in
                if !newValue.isEmpty {
                    withAnimation(.easeIn) {
                        showValueField = true
                    }
                }
            }
            .padding(.top, showValueField ? 17 : 0)
            .background(
                Text(placeHolder)
                    .font(.system(size: showValueField ? 14 : 16))
                    .foregroundColor(colorScheme == .light ? Color.label.opacity(0.55) : Color.label.opacity(0.75))
                    .offset(
                        y: showValueField ? -11 : 0
                    ),
                alignment: .leading
            )
            .padding(EdgeInsets(
                top: 0,
                leading: 13,
                bottom: 0,
                trailing: 0
            ))
        }
        .onAppear(perform: {
            if value != "" {
                showValueField = true
            }
        })
        .frame(height: 51)
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.systemGray4, lineWidth: 1)
        )
    }
}

struct CustomTextFieldView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomTextFieldView(
                value: .constant(""),
                placeHolder: "Full Name",
                keyboardType: .default
            )

            CustomTextFieldView(
                value: .constant("Mahmudul Hasan Shohag"),
                placeHolder: "Full Name",
                keyboardType: .default
            )

            CustomTextFieldView(
                value: .constant("   "),
                placeHolder: "Full Name",
                keyboardType: .default
            )
        }
        .padding()
    }
}
