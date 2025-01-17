//
//  Copyright © 2022 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import UIKit

/// Component Name: `JailBroken Checker`
/// Version: `1.1.230216`

/// This file contains a comprehensive checks to find out if the device is jail-broken.
///
/// Note: Must add the following to your plist file:
///
/// ```
/// <key>LSApplicationQueriesSchemes</key>
/// <array>
///     <string>cydia</string>
/// </array>
/// ```
///
/// Reference source:
/// - https://github.com/thii/DTTJailbreakDetection (Used by https://gonative.io/docs/jailbreak-root-detection)
/// - https://github.com/SachinSabat/CheckJailBreakDevice
/// - https://github.com/developerinsider/isJailBroken

public extension UIDevice {
    var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }

    var isJailBroken: Bool {
        #if DEBUG
        if UIDevice.current.isSimulator { return false }
        #endif
        if JailBrokenHelper.hasCydiaInstalled() { return true }
        if JailBrokenHelper.isContainsSuspiciousApps() { return true }
        if JailBrokenHelper.isSuspiciousSystemPathsExists() { return true }
        return JailBrokenHelper.canEditSystemFiles()
    }
}

private enum JailBrokenHelper {
    // check if cydia is installed (using URI Scheme)
    @MainActor
    static func hasCydiaInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
    }

    // Check if suspicious apps (Cydia, FakeCarrier, Icy etc.) is installed
    static func isContainsSuspiciousApps() -> Bool {
        for path in suspiciousAppsPathToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }

    // Check if system contains suspicious files
    static func isSuspiciousSystemPathsExists() -> Bool {
        for path in suspiciousPathsToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }

    // Check if app can edit system files
    static func canEditSystemFiles() -> Bool {
        let jailBreakText = "Lorem Ipsum"
        do {
            try jailBreakText.write(toFile: "/private/jailbreak.txt", atomically: true, encoding: .utf8)

            // ----------------------------------------------------------------
            // If file creation succeeded, we will delete the file.
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: "/private/jailbreak.txt")
            } catch {}
            // ----------------------------------------------------------------

            return true
        } catch {
            return false
        }
    }

    static var suspiciousAppsPathToCheck: [String] {
        return [
            "/Applications/Cydia.app",
            "/Applications/FakeCarrier.app",
            "/Applications/Icy.app",
            "/Applications/IntelliScreen.app",
            "/Applications/MxTube.app",
            "/Applications/RockApp.app",
            "/Applications/SBSettings.app",
            "/Applications/Snoop-itConfig.app",
            "/Applications/WinterBoard.app",
            "/Applications/blackra1n.app",
        ]
    }

    static var suspiciousPathsToCheck: [String] {
        return [
            // Files
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/bin.sh",
            "/bin/bash",
            "/bin/sh",
            "/etc/apt",
            "/private/var/lib/apt",
            "/private/var/lib/cydia",
            "/private/var/mobile/Library/SBSettings/Themes",
            "/private/var/stash",
            "/private/var/tmp/cydia.log",
            "/private/var/jb/xina",
            "/usr/bin/cycript",
            "/usr/bin/ssh",
            "/usr/bin/sshd",
            "/usr/lib/libcycript.dylib",
            "/usr/libexec/sftp-server",
            "/usr/libexec/ssh-keysign",
            "/usr/local/bin/cycript",
            "/usr/sbin/frida-server",
            "/usr/sbin/sshd",
            "/var/checkra1n.dmg",
            // Directories
            "/private/var/lib/apt/",
            "/usr/libexec/cydia/",
        ]
    }
}
