//
//  Copyright © 2023 Apple Inc. All rights reserved.
//

import SwiftUI

#if DEBUG

struct NavigationDemo: View {
    @ObservedObject var navController = NavController.shared

    var body: some View {
        NavigationStack(path: $navController.navStack) {
            NavigationDemoScreen("Root")
                .navigationDestination(for: Destination.self) { destination in
                    switch destination {
                    case .A:
                        NavigationDemoScreen("A")

                    case .B:
                        NavigationDemoScreen("B")

                    case .C:
                        NavigationDemoScreen("C")

                    default:
                        NavigationDemoScreen("\(destination)")
                    }
                }
        }
    }
}

struct NavigationDemoScreen: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var navController = NavController.shared

    private let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Root > \(navController.description())")
                    .monospaced()
                    .padding()

                Group {
                    Button {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                    }

                    Button {
                        navController.popUpToRoot()
                    } label: {
                        Text("Back to `Root`")
                    }

                    HStack(spacing: 8) {
                        Button {
                            navController.navigateTo(.A)
                        } label: {
                            Text("Nav to `A`")
                        }

                        Button {
                            navController.navigateTo(.B)
                        } label: {
                            Text("Nav to `B`")
                        }

                        Button {
                            navController.navigateTo(.C(id: UUID().hashValue))
                        } label: {
                            Text("Nav to `C`")
                        }
                    }

                    Button {
                        navController.navigateTo(.B, popUpTo: .A)
                    } label: {
                        Text("`popUpTo(.A)`\n**Nav to `B`**")
                    }

                    Button {
                        navController.navigateTo(.B, popUpTo: .A, inclusive: true)
                    } label: {
                        Text("`popUpTo(.A, inclusive: true)`\n**Nav to `B`**")
                    }

                    Button {
                        navController.navigateTo(.B, launchSingleTop: true, popUpTo: .A, inclusive: true)
                    } label: {
                        Text("`popUpTo(.A, inclusive: true)`\n**Nav to `B` with `launchSingleTop`**")
                    }

                    Button {
                        navController.popBackStack()
                    } label: {
                        Text("`popBackStack()`")
                    }

                    HStack(spacing: 8) {
                        Button {
                            navController.popUpTo(.A)
                        } label: {
                            Text("`popUpTo(.A)`")
                        }

                        Button {
                            navController.popUpTo(.B)
                        } label: {
                            Text("`popUpTo(.B)`")
                        }

                        Button {
                            navController.popUpTo(.C(id: UUID().hashValue))
                        } label: {
                            Text("`popUpTo(.C)`")
                        }
                    }

                    HStack(spacing: 8) {
                        Button {
                            navController.popUpTo(.A, inclusive: true)
                        } label: {
                            Text("`popUpTo(.A)`\n**`inclusive`**")
                        }

                        Button {
                            navController.popUpTo(.B, inclusive: true)
                        } label: {
                            Text("`popUpTo(.B)`\n**`inclusive`**")
                        }

                        Button {
                            navController.popUpTo(.C(id: UUID().hashValue), inclusive: true)
                        } label: {
                            Text("`popUpTo(.C)`\n**`inclusive`**")
                        }
                    }
                }
                .buttonStyle(.bordered)
                .font(.footnote)
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NavigationDemo_Previews: PreviewProvider {
    static var previews: some View {
        NavigationDemo()
    }
}

#endif
