//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import SwiftUI

#if DEBUG

struct NavigationDemo: View {
    @ObservedObject var navController = NavController.shared

    var body: some View {
        NavigationStack(path: $navController.navStack) {
            NavigationDemoScreen("Root")
                .navigationDestination(for: BaseDestination.self) { destination in
                    AnyView(destination.getScreen())
                }
                .onChange(of: navController.navStack) {
                    SuperLog.v("navStack: \(navController.navStack)")
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
                    .font(.footnote)
                    .monospaced()
                    .padding([.leading, .trailing, .bottom])

                Group {
                    HStack(spacing: 8) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Dismiss")
                        }

                        Button {
                            navController.popBackStack()
                        } label: {
                            Text("`popBackStack()`")
                        }

                        Button {
                            navController.popUpToRoot()
                        } label: {
                            Text("Back to `Root`")
                        }
                    }

                    HStack(spacing: 8) {
                        Button {
                            navController.navigateTo(Destination.A())
                        } label: {
                            Text("Nav to `A`")
                        }

                        Button {
                            navController.navigateTo(Destination.B())
                        } label: {
                            Text("Nav to `B`")
                        }

                        Button {
                            navController.navigateTo(Destination.C(id: UUID().hashValue))
                        } label: {
                            Text("Nav to `C`")
                        }
                    }

                    Button {
                        navController.navigateTo(
                            [
                                Destination.A(),
                                Destination.B(),
                                Destination.C(id: UUID().hashValue)
                            ]
                        )
                    } label: {
                        Text("Nav to `[A, B, C]`")
                    }

                    Button {
                        navController.navigateTo(
                            [
                                Destination.A(),
                                Destination.B(),
                                Destination.C(id: UUID().hashValue)
                            ],
                            popUpTo: Destination.A.self,
                            inclusive: true
                        )
                    } label: {
                        Text("`popUpTo(.A, inclusive: true)`\n**Nav to `[A, B, C]`**")
                    }

                    HStack(spacing: 8) {
                        Button {
                            navController.navigateTo(Destination.B(), popUpTo: Destination.A.self)
                        } label: {
                            Text("`popUpTo(.A)`\n**Nav to `B`**")
                        }

                        Button {
                            navController.navigateTo(Destination.C(id: UUID().hashValue), popUpTo: Destination.B.self)
                        } label: {
                            Text("`popUpTo(.B)`\n**Nav to `C`**")
                        }

                        Button {
                            navController.navigateTo(Destination.A(), popUpTo: Destination.C.self)
                        } label: {
                            Text("`popUpTo(.C)`\n**Nav to `A`**")
                        }
                    }

                    Button {
                        navController.navigateTo(Destination.B(), popUpTo: Destination.A.self, inclusive: true)
                    } label: {
                        Text("`popUpTo(.A, inclusive: true)`\n**Nav to `B`**")
                    }

                    Button {
                        navController.navigateTo(Destination.B(), launchSingleTop: true, popUpTo: Destination.A.self, inclusive: true)
                    } label: {
                        Text("`popUpTo(.A, inclusive: true)`\n**Nav to `B` with `launchSingleTop`**")
                    }

                    HStack(spacing: 8) {
                        Button {
                            navController.popUpTo(Destination.A.self)
                        } label: {
                            Text("`popUpTo(.A)`")
                        }

                        Button {
                            navController.popUpTo(Destination.B.self)
                        } label: {
                            Text("`popUpTo(.B)`")
                        }

                        Button {
                            navController.popUpTo(Destination.C.self)
                        } label: {
                            Text("`popUpTo(.C)`")
                        }
                    }

                    HStack(spacing: 8) {
                        Button {
                            navController.popUpTo(Destination.A.self, inclusive: true)
                        } label: {
                            Text("`popUpTo(.A)`\n**`inclusive`**")
                        }

                        Button {
                            navController.popUpTo(Destination.B.self, inclusive: true)
                        } label: {
                            Text("`popUpTo(.B)`\n**`inclusive`**")
                        }

                        Button {
                            navController.popUpTo(Destination.C.self, inclusive: true)
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
