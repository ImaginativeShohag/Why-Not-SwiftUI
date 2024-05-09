//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

@testable import Core
import Foundation
import Moya
import XCTest

class ArrayMultipartFormDataAppendTest: XCTestCase {
    // MARK: - Value

    func testAppend_keyValueString_shouldAdd() {
        var list = [MultipartFormData]()

        list.append(key: "key1", value: "value1")
        list.append(key: "key2", value: "value2")
        list.append(key: "key3", value: "value3")

        XCTAssertEqual(list.count, 3)
        XCTAssertTrue(list[0].name == "key1")
        XCTAssertTrue(list[0].provider == .data("value1".data(using: .utf8)!))
        XCTAssertTrue(list[1].name == "key2")
        XCTAssertTrue(list[1].provider == .data("value2".data(using: .utf8)!))
        XCTAssertTrue(list[2].name == "key3")
        XCTAssertTrue(list[2].provider == .data("value3".data(using: .utf8)!))
    }
    
    func testAppend_keyValueInt_shouldAdd() {
        var list = [MultipartFormData]()

        list.append(key: "key1", value: 1)
        list.append(key: "key2", value: Int.min)
        list.append(key: "key3", value: Int.max)

        XCTAssertEqual(list.count, 3)
        XCTAssertTrue(list[0].name == "key1")
        XCTAssertTrue(list[0].provider == .data("\(1)".data(using: .utf8)!))
        XCTAssertTrue(list[1].name == "key2")
        XCTAssertTrue(list[1].provider == .data("\(Int.min)".data(using: .utf8)!))
        XCTAssertTrue(list[2].name == "key3")
        XCTAssertTrue(list[2].provider == .data("\(Int.max)".data(using: .utf8)!))
    }

    func testAppend_keyValueArray_addShouldAdd() {
        var list = [MultipartFormData]()

        list.append([
            "key1": "value1",
            "key2": "value2",
            "key3": "value3",
        ])

        let item1 = list.first { $0.name == "key1" }

        XCTAssertEqual(list.count, 3)

        XCTAssertTrue(item1?.name == "key1")
        XCTAssertTrue(item1?.provider == .data("value1".data(using: .utf8)!))
    }

    // MARK: - File

    func testAppend_file_addShouldAdd() {
        var list = [MultipartFormData]()

        list.append(
            key: "key1",
            file: URL(string: "file:///folder/test.mov")!,
            fileName: "video.mov",
            mimeType: "video/quicktime"
        )

        XCTAssertEqual(list.count, 1)
        XCTAssertTrue(list.first?.name == "key1")
        XCTAssertTrue(list.first?.provider == .file(URL(string: "file:///folder/test.mov")!))
        XCTAssertTrue(list.first?.fileName == "video.mov")
        XCTAssertTrue(list.first?.mimeType == "video/quicktime")
    }

    // MARK: - Data

    func testAppend_data_addShouldAdd() {
        var list = [MultipartFormData]()

        let imageData = UIImage(systemName: "star")!.jpegData(compressionQuality: 0.5)!

        list.append(
            key: "key1",
            data: imageData,
            fileName: "image.jpeg",
            mimeType: "image/jpeg"
        )

        XCTAssertEqual(list.count, 1)
        XCTAssertTrue(list.first?.name == "key1")
        XCTAssertTrue(list.first?.provider == .data(imageData))
        XCTAssertTrue(list.first?.fileName == "image.jpeg")
        XCTAssertTrue(list.first?.mimeType == "image/jpeg")
    }

    // MARK: - Attachment

    func testAppend_attachments_shouldAdd() {
        var list = [MultipartFormData]()

        let imageAttachment = UIImage(systemName: "star")!
        let videoAttachment = URL(string: "file:///folder/test.mov")!

        let attachments: [Any] = [
            imageAttachment,
            videoAttachment,
        ]

        list.append(
            attachments,
            key: "attachments"
        )

        XCTAssertEqual(list.count, 2)

        XCTAssertTrue(list.first?.name == "attachments[0]")
        XCTAssertTrue(list.first?.provider == .data(imageAttachment.jpegData(compressionQuality: 0.5)!))
        XCTAssertTrue(list.first?.fileName == "image0.jpeg")
        XCTAssertTrue(list.first?.mimeType == "image/jpeg")

        XCTAssertTrue(list[1].name == "attachments[1]")
        XCTAssertTrue(list[1].provider == .file(videoAttachment))
        XCTAssertTrue(list[1].fileName == "video1.mov")
        XCTAssertTrue(list[1].mimeType == "video/quicktime")
    }

    // MARK: - Array of String

    func testAppend_arrayOfString_shouldAdd() {
        var list = [MultipartFormData]()

        let strings: [String] = [
            "test one",
            "test two",
        ]

        list.append(
            strings,
            key: "strings"
        )

        XCTAssertEqual(list.count, 2)

        XCTAssertTrue(list.first?.name == "strings[0]")
        XCTAssertTrue(list.first?.provider == .data("test one".data(using: .utf8)!))

        XCTAssertTrue(list[1].name == "strings[1]")
        XCTAssertTrue(list[1].provider == .data("test two".data(using: .utf8)!))
    }
}
