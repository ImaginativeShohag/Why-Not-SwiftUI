//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import XCTest

class FileExtensionTests: XCTestCase {
    // Basic cases
    func testFileWithExtension() {
        XCTAssertEqual("file.txt".fileExtension(), "txt")
        XCTAssertEqual("image.jpeg".fileExtension(), "jpeg")
        XCTAssertEqual("document.pdf".fileExtension(), "pdf")
    }

    // Files with multiple dots
    func testFileWithMultipleDots() {
        XCTAssertEqual("archive.tar.gz".fileExtension(), "gz")
        XCTAssertEqual("report.final.docx".fileExtension(), "docx")
    }

    // No extension
    func testFileWithoutExtension() {
        XCTAssertEqual("file".fileExtension(), "")
        XCTAssertEqual("folder/file".fileExtension(), "")
    }

    // Hidden files and folders
    func testHiddenFile() {
        XCTAssertEqual(".gitignore".fileExtension(), "")
        XCTAssertEqual(".hiddenfile.txt".fileExtension(), "txt")
    }

    // Special characters
    func testFileWithSpecialCharacters() {
        XCTAssertEqual("data@info!.xml".fileExtension(), "xml")
        XCTAssertEqual("my_file (copy).mp3".fileExtension(), "mp3")
    }

    // Empty string
    func testEmptyString() {
        XCTAssertEqual("".fileExtension(), "")
    }

    // Paths with directories
    func testFilePathWithDirectories() {
        XCTAssertEqual("/path/to/file.html".fileExtension(), "html")
        XCTAssertEqual("/another/path/file".fileExtension(), "")
    }

    // URLs
    func testURLString() {
        XCTAssertEqual("https://example.com/file.zip".fileExtension(), "zip")
        XCTAssertEqual("http://example.com/folder/file".fileExtension(), "")
    }

    // File name with a dot at the end
    func testFileWithDotAtEnd() {
        XCTAssertEqual("filename.".fileExtension(), "")
    }

    func testURLWithQueryParameters() {
        XCTAssertEqual("https://example.com/file.mp4?token=abc123".fileExtension(), "mp4")
        XCTAssertEqual("https://example.com/path/file.json?user=xyz&version=2".fileExtension(), "json")
    }
}
