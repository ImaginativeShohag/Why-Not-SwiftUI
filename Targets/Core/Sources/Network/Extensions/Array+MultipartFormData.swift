//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import Moya
import UIKit

public extension Array where Element == MultipartFormData {
    // MARK: - Value

    /// Append `String` values.
    ///
    /// Tested: `ArrayMultipartFormDataAppendTest`
    mutating func append(key: String, value: String) {
        self.append(
            MultipartFormData(
                provider: .data(value.data(using: .utf8)!),
                name: key
            )
        )
    }

    /// Append `Bool` values.
    ///
    /// Tested: `ArrayMultipartFormDataAppendTest`
    mutating func append(key: String, value: Bool) {
        self.append(
            MultipartFormData(
                provider: .data("\(value ? 1 : 0)".data(using: .utf8)!),
                name: key
            )
        )
    }

    /// Append `Int` values.
    ///
    /// Tested: `ArrayMultipartFormDataAppendTest`
    mutating func append(key: String, value: Int) {
        self.append(
            MultipartFormData(
                provider: .data("\(value)".data(using: .utf8)!),
                name: key
            )
        )
    }

    /// Append multiple `String` values.
    ///
    /// Tested: `ArrayMultipartFormDataAppendTest`
    mutating func append(_ elements: [String: String]) {
        for (key, value) in elements {
            self.append(
                MultipartFormData(
                    provider: .data(value.data(using: .utf8)!),
                    name: key
                )
            )
        }
    }

    // MARK: - File

    /// Append file using `URL`.
    ///
    /// Tested: `ArrayMultipartFormDataAppendTest`
    mutating func append(key: String, file: URL, fileName: String? = nil, mimeType: String? = nil) {
        self.append(
            MultipartFormData(
                provider: .file(file),
                name: key,
                fileName: fileName,
                mimeType: mimeType
            )
        )
    }

    // MARK: - Data

    /// Append `Data`. For example image.
    ///
    /// Tested: `ArrayMultipartFormDataAppendTest`
    mutating func append(key: String, data: Data, fileName: String? = nil, mimeType: String? = nil) {
        self.append(
            MultipartFormData(
                provider: .data(data),
                name: key,
                fileName: fileName,
                mimeType: mimeType
            )
        )
    }

    // MARK: - Attachment

    /// Append attachments.
    ///
    /// - Parameter elements: Supported type: Local QuickTime video `URL` and `UIImage`.
    /// - Parameter key: The attachment array key. For example: `attachments` etc.
    ///
    /// Tested: `ArrayMultipartFormDataAppendTest`
    mutating func append(_ elements: [Any], key: String) {
        for (index, attachment) in elements.enumerated() {
            if attachment is URL, (attachment as! URL).isLocalQuickTimeVideoURL() {
                self.append(
                    key: "\(key)[\(index)]",
                    file: attachment as! URL,
                    fileName: "video\(index).mov",
                    mimeType: "video/quicktime"
                )
            } else if attachment is UIImage {
                let imageData = (attachment as! UIImage).jpegData(compressionQuality: 0.5)!

                self.append(
                    key: "\(key)[\(index)]",
                    data: imageData,
                    fileName: "image\(index).jpeg",
                    mimeType: "image/jpeg"
                )
            } else {
                CoolLog.v("Unknown object: \(attachment)")
            }
        }
    }

    // MARK: - Array of String

    /// Append `Array` of `String`.
    ///
    /// - Parameter elements: `Array` of  `String`.
    /// - Parameter key: The `String` array key. For example: `comments` etc.
    ///
    /// Tested: `ArrayMultipartFormDataAppendTest`
    mutating func append(_ elements: [String], key: String) {
        for (index, value) in elements.enumerated() {
            self.append(
                key: "\(key)[\(index)]",
                value: value
            )
        }
    }
}
