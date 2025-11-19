//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SuperLog
import SwiftUI

// Note: Check the code for "rootOne", "rootTwo" and "rootThree" before check the demo.

#if DEBUG

enum RootScreen {
    case rootOne
    case rootTwo
    case rootThree
}

@MainActor
@Observable
class RootScreenController {
    static let shared = RootScreenController()

    var currentRootScreen: RootScreen = .rootOne

    private init() {}

    func changeRoot(to screen: RootScreen) {
        SuperLog.v("screen: \(screen) \(Thread.isMainThread)")

        currentRootScreen = screen
    }
}

extension NavController {
    func changeAndPopUpTo(root screen: RootScreen) {
        SuperLog.v("screen: \(screen) \(Thread.isMainThread)")

        RootScreenController.shared.changeRoot(to: screen)
        popUpToRoot()
    }
}

@MainActor
struct MultiNavigationDemo: View {
    @Bindable var rootScreenController = RootScreenController.shared

    var body: some View {
        ZStack {
            switch rootScreenController.currentRootScreen {
            case .rootOne:
                NavControllerStack(navController: NavController.rootOne) {
                    MultiNavigationDemoOneScreen()
                        .border(Color.red, width: 8)
                }

            case .rootTwo:
                NavControllerStack(navController: NavController.rootTwo) {
                    MultiNavigationDemoTwoScreen()
                        .border(Color.green, width: 8)
                }

            case .rootThree:
                NavControllerStack(navController: NavController.rootThree) {
                    MultiNavigationDemoThreeScreen()
                        .border(Color.blue, width: 8)
                }
            }
        }
    }
}

extension NavController {
    // Note: To make the demo work create new instance for the NavController.
    static let rootOne = NavController.shared // NavController()
    static let rootTwo = NavController.shared // NavController()
    static let rootThree = NavController.shared // NavController()
}

struct NavControllerStack<RootContent: View>: View {
    @Bindable private var navController: NavController

    @ViewBuilder
    private var rootContent: () -> RootContent

    init(
        navController: NavController,
        rootContent: @escaping () -> RootContent
    ) {
        self.navController = navController
        self.rootContent = rootContent
    }

    var body: some View {
        NavigationStack(path: $navController.navStack) {
            rootContent()
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
            title: "One",
            navController: NavController.rootOne
        )
    }
}

private struct MultiNavigationDemoTwoScreen: View {
    var body: some View {
        MultiNavigationDemoScreen(
            title: "Two",
            navController: NavController.rootTwo
        )
    }
}

private struct MultiNavigationDemoThreeScreen: View {
    var body: some View {
        MultiNavigationDemoScreen(
            title: "Three",
            navController: NavController.rootThree
        )
    }
}

extension Destination {
    final class X: BaseDestination {
        let navController: NavController
        
        let uuid = UUID()

        init(navController: NavController) {
            self.navController = navController
        }

        override func getScreen() -> any View {
            MultiNavigationDemoScreen(
                title: "\(route) \(uuid)",
                navController: navController
            )
        }
    }
}

private struct MultiNavigationDemoScreen: View {
    @Environment(\.dismiss) private var dismiss

    private let title: String
    private let navController: NavController

    init(title: String, navController: NavController) {
        self.title = title
        self.navController = navController
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
    MultiNavigationDemo()
}

#endif
