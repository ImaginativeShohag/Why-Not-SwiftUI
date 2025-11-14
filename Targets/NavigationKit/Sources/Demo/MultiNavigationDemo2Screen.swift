//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SuperLog
import SwiftUI

#if DEBUG

@MainActor
struct MultiNavigation2Demo: View {
    @Bindable private var navController = NavController.shared
    @Bindable var rootScreenController = RootScreenController.shared

    var body: some View {
        NavigationStack(path: $navController.navStack) {
            Group {
                switch rootScreenController.currentRootScreen {
                case .rootOne:
                    MultiNavigationDemoOneScreen()
                        .border(Color.red, width: 8)

                case .rootTwo:
                    MultiNavigationDemoTwoScreen()
                        .border(Color.green, width: 8)

                case .rootThree:
                    MultiNavigationDemoThreeScreen()
                        .border(Color.blue, width: 8)
                }
            }
            .navigationDestination(for: BaseDestination.self) { destination in
                AnyView(destination.getScreen())
            }
            .onChange(of: navController.navStack) {
                SuperLog.v("navStack: \(navController.navStack)")
            }
        }
    }
}

private struct MultiNavigationDemoOneScreen: View {
    var body: some View {
        MultiNavigationDemoScreen(
            title: "One"
        )
    }
}

private struct MultiNavigationDemoTwoScreen: View {
    var body: some View {
        MultiNavigationDemoScreen(
            title: "Two"
        )
    }
}

private struct MultiNavigationDemoThreeScreen: View {
    var body: some View {
        MultiNavigationDemoScreen(
            title: "Three"
        )
    }
}

private struct MultiNavigationDemoScreen: View {
    @Environment(\.dismiss) private var dismiss

    private let title: String
    private let navController = NavController.shared

    init(title: String) {
        self.title = title
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Root > \(navController.description())")
                    .font(.footnote)
                    .monospaced()
                    .padding([.leading, .trailing, .bottom])

                Group {
                    HStack(spacing: 8) {
                        Button {
                            navController.changeAndPopUpTo(root: .rootOne)
                        } label: {
                            Text("Root \(Image(systemName: "1.circle"))")
                        }
                        .tint(.red)

                        Button {
                            navController.changeAndPopUpTo(root: .rootTwo)
                        } label: {
                            Text("Root \(Image(systemName: "2.circle"))")
                        }
                        .tint(.green)

                        Button {
                            navController.changeAndPopUpTo(root: .rootThree)
                        } label: {
                            Text("Root \(Image(systemName: "3.circle"))")
                        }
                        .tint(.blue)
                    }
                    .buttonStyle(.borderedProminent)

                    HStack(spacing: 8) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Dismiss")
                        }

                        Button {
                            navController.navigateTo(Destination.X(navController: navController))
                        } label: {
                            Text("Next")
                        }
                    }
                }
                .buttonStyle(.bordered)
                .font(.footnote)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            SuperLog.v("\(title) task")
        }
        .onAppear {
            SuperLog.v("\(title) onAppear")
        }
        .onDisappear {
            SuperLog.v("\(title) onDisappear")
        }
    }
}

#Preview {
    MultiNavigation2Demo()
}

#endif
