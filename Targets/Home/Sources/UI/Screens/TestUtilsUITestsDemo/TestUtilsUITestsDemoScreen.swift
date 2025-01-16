//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import NavigationKit
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class TestUtilsUITestsDemo: BaseDestination {
        override public func getScreen() -> any View {
            TestUtilsUITestsDemoScreen()
        }
    }
}

// MARK: - UI

struct TestUtilsUITestsDemoScreen: View {
    @State var showWelcomeText: Bool = false
    @State var showLoading: Bool = false
    var body: some View {
        ZStack {
            if showLoading {
                ProgressView()
            } else {
                VStack(spacing: 20) {
                    Text("This screen is specifically designed for performing UI tests, utilizing extensions from the **TestUtils** target")
                        .font(.footnote)
                        .multilineTextAlignment(.center)

                    Divider()

                    VStack(spacing: 20) {
                        if showWelcomeText {
                            Text("Welcome...")
                        }

                        Button {
                            showLoading = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showWelcomeText = true
                                showLoading = false
                            }
                        } label: {
                            Text("Show Welcome Text")
                        }
                        .buttonStyle(.bordered)
                        .disabled(showWelcomeText)
                        .accessibilityIdentifier("text_show_button")

                        Button("Hide Welcome Text") {
                            showWelcomeText = false
                        }
                        .buttonStyle(.bordered)
                        .disabled(!showWelcomeText)
                        .accessibilityIdentifier("text_hide_button")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("TestUtilsUITestsDemoScreen")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        TestUtilsUITestsDemoScreen()
    }
}
