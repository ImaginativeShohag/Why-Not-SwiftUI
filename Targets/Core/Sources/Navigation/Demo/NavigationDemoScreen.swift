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
                            navController.navigateTo(BaseDestination.A())
                        } label: {
                            Text("Nav to `A`")
                        }

                        Button {
                            navController.navigateTo(BaseDestination.B())
                        } label: {
                            Text("Nav to `B`")
                        }

                        Button {
                            navController.navigateTo(BaseDestination.C(id: UUID().hashValue))
                        } label: {
                            Text("Nav to `C`")
                        }
                    }

                    HStack(spacing: 8) {
                        Button {
                            navController.navigateTo(BaseDestination.B(), popUpTo: BaseDestination.A.self)
                        } label: {
                            Text("`popUpTo(.A)`\n**Nav to `B`**")
                        }
                        
                        Button {
                            navController.navigateTo(BaseDestination.C(id: UUID().hashValue), popUpTo: BaseDestination.B.self)
                        } label: {
                            Text("`popUpTo(.B)`\n**Nav to `C`**")
                        }
                        
                        Button {
                            navController.navigateTo(BaseDestination.A(), popUpTo: BaseDestination.C.self)
                        } label: {
                            Text("`popUpTo(.C)`\n**Nav to `A`**")
                        }
                    }

                    Button {
                        navController.navigateTo(BaseDestination.B(), popUpTo: BaseDestination.A.self, inclusive: true)
                    } label: {
                        Text("`popUpTo(.A, inclusive: true)`\n**Nav to `B`**")
                    }

                    Button {
                        navController.navigateTo(BaseDestination.B(), launchSingleTop: true, popUpTo: BaseDestination.A.self, inclusive: true)
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
                            navController.popUpTo(BaseDestination.A.self)
                        } label: {
                            Text("`popUpTo(.A)`")
                        }

                        Button {
                            navController.popUpTo(BaseDestination.B.self)
                        } label: {
                            Text("`popUpTo(.B)`")
                        }

                        Button {
                            navController.popUpTo(BaseDestination.C.self)
                        } label: {
                            Text("`popUpTo(.C)`")
                        }
                    }

                    HStack(spacing: 8) {
                        Button {
                            navController.popUpTo(BaseDestination.A.self, inclusive: true)
                        } label: {
                            Text("`popUpTo(.A)`\n**`inclusive`**")
                        }

                        Button {
                            navController.popUpTo(BaseDestination.B.self, inclusive: true)
                        } label: {
                            Text("`popUpTo(.B)`\n**`inclusive`**")
                        }

                        Button {
                            navController.popUpTo(BaseDestination.C.self, inclusive: true)
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
