//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Kingfisher
import SwiftUI
import NavigationKit

struct ProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ProfileViewModel
    @State private var showSignOutAlert: Bool = false

    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.state {
                case .loading:
                    ProgressView()

                case .error(let message):
                    ContentUnavailableView(
                        label: {
                            Label(message, systemImage: "exclamationmark.triangle")
                        },
                        actions: {
                            Button("Retry") {
                                Task {
                                    await viewModel.getUserDetails()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top)
                        }
                    )

                case .data(let user):
                    VStack {
                        Form {
                            HStack(alignment: .center) {
                                KFImage(URL(string: "https://picsum.photos/id/42/200/200"))
                                    .placeholder {
                                        Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .foregroundStyle(Color(.label).opacity(0.5))
                                    }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .clipped()
                            }
                            .frame(maxWidth: .infinity)

                            Section("Details") {
                                LabeledContent(
                                    "Name",
                                    value: user.name.getFullName()
                                )
                                LabeledContent("Username", value: user.username)
                                LabeledContent("Email", value: user.email)
                                LabeledContent("Phone", value: user.phone)
                                LabeledContent(
                                    "Address",
                                    value: user.address?.getAddress() ?? "-"
                                )
                            }
                            
                            Section {
                                Button("Sign Out") {
                                    showSignOutAlert.toggle()
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.systemGroupedBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .refreshable {
                await viewModel.getUserDetails()
            }
            .task {
                await viewModel.getUserDetails()
            }
            .alert(
                "Signout from Store?",
                isPresented: $showSignOutAlert) {
                    Button("Sign Out", role: .destructive) {
                        viewModel.signOut()
                        
                        NavController.shared.navigateTo(
                            Destination.StoreLogin(),
                            popUpTo: Destination.Main.self,
                            inclusive: true
                        )
                    }
                    .tint(.red)
                }
        }
    }
}

#if DEBUG

#Preview("With Data") {
    ZStack {
        Text("Nothing")
    }
    .sheet(isPresented: .constant(true)) {
        ProfileSheet(
            viewModel: .init(
                forPreview: true,
                isLoading: false,
                isError: false
            )
        )
    }
}

#Preview("With Error") {
    ZStack {
        Text("Nothing")
    }
    .sheet(isPresented: .constant(true)) {
        ProfileSheet(
            viewModel: .init(
                forPreview: true,
                isLoading: false,
                isError: true
            )
        )
    }
}

#Preview("Loading") {
    ZStack {
        Text("Nothing")
    }
    .sheet(isPresented: .constant(true)) {
        ProfileSheet(
            viewModel: .init(
                forPreview: true,
                isLoading: true,
                isError: false
            )
        )
    }
}

#endif
