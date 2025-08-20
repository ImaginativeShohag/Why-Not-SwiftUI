//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Core
import NavigationKit
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
            Section(header: Text(NSLocalizedString("description_section_header", bundle: .module, comment: ""))) {
                Text(NSLocalizedString("app_storage_description_text", bundle: .module, comment: ""))
            }

            Section(header: Text(NSLocalizedString("notifications_menu_item_title", bundle: .module, comment: ""))) {
                Picker(NSLocalizedString("notify_me_about_picker_label", bundle: .module, comment: ""), selection: $notifyMeAbout) {
                    Text(NSLocalizedString("direct_messages_notification_option", bundle: .module, comment: "")).tag(NotifyMeAboutType.directMessages)
                    Text(NSLocalizedString("notification_option_mentions", bundle: .module, comment: "")).tag(NotifyMeAboutType.mentions)
                    Text("Anything").tag(NotifyMeAboutType.anything)
                }
                Toggle(NSLocalizedString("play_notification_sounds_toggle_label", bundle: .module, comment: ""), isOn: $playNotificationSounds)
                Toggle(NSLocalizedString("send_read_receipts_toggle_label", bundle: .module, comment: ""), isOn: $sendReadReceipts)
            }

            Section(header: Text(NSLocalizedString("user_profiles_section_header", bundle: .module, comment: ""))) {
                Picker(NSLocalizedString("profile_image_size_picker_label", bundle: .module, comment: ""), selection: $profileImageSize) {
                    Text(NSLocalizedString("profile_image_size_large_option", bundle: .module, comment: "")).tag(ProfileImageSize.large)
                    Text(NSLocalizedString("mentions_notification_option", bundle: .module, comment: "")).tag(ProfileImageSize.medium)
                    Text(NSLocalizedString("profile_image_size_small_option", bundle: .module, comment: "")).tag(ProfileImageSize.small)
                }
            }
        }
        .navigationTitle(NSLocalizedString("app_storage_example", bundle: .module, comment: ""))
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
