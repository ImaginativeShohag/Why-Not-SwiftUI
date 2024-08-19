//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import SwiftUI

// MARK: - Destination

public extension Destination {
    final class AppStorage: BaseDestination {
        override public func getScreen() -> any View {
            AppStorageScreen()
        }
    }
}

// MARK: - UI

struct AppStorageScreen: View {
    @AppStorage("notifyMeAbout") private var notifyMeAbout: NotifyMeAboutType = .anything
    @AppStorage("playNotificationSounds") private var playNotificationSounds: Bool = true
    @AppStorage("sendReadReceipts") private var sendReadReceipts: Bool = true
    @AppStorage("profileImageSize") private var profileImageSize: ProfileImageSize = .large

    var body: some View {
        Form {
            Section(header: Text("Description")) {
                Text("This screen demonstrate example for `@AppStorage`. All the value here are coming form `UserDefaults` using `@AppStorage`.")
            }

            Section(header: Text("Notifications")) {
                Picker("Notify Me About", selection: $notifyMeAbout) {
                    Text("Direct Messages").tag(NotifyMeAboutType.directMessages)
                    Text("Mentions").tag(NotifyMeAboutType.mentions)
                    Text("Anything").tag(NotifyMeAboutType.anything)
                }
                Toggle("Play notification sounds", isOn: $playNotificationSounds)
                Toggle("Send read receipts", isOn: $sendReadReceipts)
            }

            Section(header: Text("User Profiles")) {
                Picker("Profile Image Size", selection: $profileImageSize) {
                    Text("Large").tag(ProfileImageSize.large)
                    Text("Medium").tag(ProfileImageSize.medium)
                    Text("Small").tag(ProfileImageSize.small)
                }
            }
        }
        .navigationTitle("@AppStorage Example")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AppStorageScreen()
    }
}

private enum NotifyMeAboutType: String {
    case directMessages
    case mentions
    case anything
}

private enum ProfileImageSize: String {
    case large
    case medium
    case small
}
