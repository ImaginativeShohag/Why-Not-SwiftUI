//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import Why_Not_SwiftUI
import XCTest

class IsLocalQuickTimeVideoURLTest: XCTestCase {
    func testIsLocalVideoURL_withLocalVideoURL_returnsTrue() {
        // Create a local video URL
        let localVideoURL = URL(fileURLWithPath: "file:///private/var/mobile/Containers/Data/Application/913E8749-AC93-48C9-96DA-301CCA46645D/tmp/70595070714__293D7CE5-555C-4701-966B-A3AA9EAA07CA.MOV")

        // Assert that the local video URL is considered a local video URL
        XCTAssertTrue(localVideoURL.isLocalQuickTimeVideoURL())
    }

    func testIsLocalVideoURL_withRemoteVideoURL_returnsFalse() {
        // Create a remote video URL
        let remoteVideoURL = URL(string: "https://example.com/video.mp4")!

        // Assert that the remote video URL is not considered a local video URL
        XCTAssertFalse(remoteVideoURL.isLocalQuickTimeVideoURL())
    }

    func testIsLocalVideoURL_withDifferentScheme_returnsFalse() {
        // Create a video URL with a different scheme
        let videoURL = URL(string: "ftp://example.com/video.mov")!

        // Assert that the video URL with a different scheme is not considered a local video URL
        XCTAssertFalse(videoURL.isLocalQuickTimeVideoURL())
    }

    func testIsLocalVideoURL_withHost_returnsFalse() {
        // Create a video URL with a host
        let videoURL = URL(string: "file://example.com/video.mp4")!

        // Assert that the video URL with a host is not considered a local video URL
        XCTAssertFalse(videoURL.isLocalQuickTimeVideoURL())
    }

    func testIsLocalVideoURL_withInvalidURL_returnsFalse() {
        // Create an invalid URL
        let invalidURL = URL(string: "invalid-url")

        // Assert that the invalid URL is not considered a local video URL
        XCTAssertFalse(invalidURL?.isLocalQuickTimeVideoURL() ?? false)
    }

    func testIsLocalVideoURL_withQueryParam_returnsTrue() {
        let URLWithQuery = URL(string: "file:///Users/user/Desktop/video.mov?foo=bar")

        XCTAssertTrue(URLWithQuery?.isLocalQuickTimeVideoURL() ?? false)
    }
}
