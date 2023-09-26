//
//  CustomAXActionsScreen.swift
//  Why Not SwiftUI
//
//  Created by Md. Mahmudul Hasan Shohag on 26/09/2023.
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

/// Resources:
/// - Accessibility actions in SwiftUI: https://swiftwithmajid.com/2021/04/15/accessibility-actions-in-swiftui/

struct CustomAXActionsScreen: View {
    @State private var showPreviewAlert = false
    @State private var showDeleteAlert = false

    // MARK: -

    @State private var countValue: Int = 0
    private let countMaxValue = 10
    private let countMinValue = 0

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Text("Adjustable Action Example")
                        .font(.title)

                    VStack {
                        Text("Item: \(countValue) piece\(countValue <= 1 ? "" : "s")")
                            .transition(.opacity)
                            .id("CounterComponent\(countValue)")

                        Button("Increment") {
                            countValue += 1
                        }

                        Button("Decrement") {
                            countValue -= 1
                        }
                    }
                    .padding()
                    /// Ignore all the elements inside the `VStack`.
                    .accessibilityElement()
                    /// Set custom label for AX tools.
                    .accessibilityLabel("Value")
                    /// Set custom value for AX tools.
                    .accessibilityValue("\(countValue) piece\(countValue <= 1 ? "" : "s")")
                    /// Add AX **Adjustable Action** support. Swipe top or bottom to change the value using VO.
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment:
                            if countValue < countMaxValue {
                                countValue += 1
                            }
                        case .decrement:
                            if countValue > countMinValue {
                                countValue -= 1
                            }
                        default:
                            return
                        }
                    }

                    Divider()
                    
                    // MARK: -

                    Text("Custom Actions Example")
                        .font(.title)

                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 8, alignment: .top),
                            count: 2
                        ),
                        spacing: 8
                    ) {
                        ForEach(1 ..< 100) { index in
                            AttachmentItem(
                                id: index,
                                onClick: {
                                    showPreviewAlert = true
                                },
                                onDeleteClick: {
                                    showDeleteAlert = true
                                }
                            )
                        }
                    }
                }
            }
            .padding(.horizontal)
            .alert("Preview dialog.", isPresented: $showPreviewAlert) {
                Button("Ok", role: .cancel) {}
            }
            .alert("Do you want to delete this?", isPresented: $showDeleteAlert) {
                Button("No", role: .cancel) {}
                Button("Yes", role: .destructive) {}
            }
        }
    }
}

#Preview("CustomAXActionsScreen") {
    CustomAXActionsScreen()
}

private struct AttachmentItem: View {
    let id: Int
    let onClick: () -> Void
    let onDeleteClick: () -> Void

    private let pictures = [
        "anastasiya-leskova-3p0nSfa5gi8-unsplash",
        "leon-rohrwild-XqJyl5FD_90-unsplash",
        "jean-philippe-delberghe-75xPHEQBmvA-unsplash",
        "shubham-dhage-_PmYFVygfak-unsplash"
    ]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(pictures[id % pictures.count])
                .resizable()
                .scaledToFill()
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .contentShape(RoundedRectangle(cornerRadius: 16))
                .padding(8)
                .onTapGesture {
                    onClick()
                }

            Button {
                onDeleteClick()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .accessibilityElement()
        /// Set custom label for AX tools.
        .accessibilityLabel("Awesome Image \(id)")
        /// Set custom hint for AX tools.
        .accessibilityHint("Double tap to view preview.")
        /// Adding custom action for `delete`.
        .accessibilityAction(named: Text("Delete")) {
            onDeleteClick()
        }
    }
}
