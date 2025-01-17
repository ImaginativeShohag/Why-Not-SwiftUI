//
//  Copyright © 2023 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import CryptoKit
import Foundation

public extension String {
    func md5() -> String {
        let digest = Insecure.MD5.hash(data: data(using: .utf8) ?? Data())

        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    /// Tested: `FileExtensionTests`
    func fileExtension() -> String {
        guard let url = URLComponents(string: self)?.url else { return "" }
        return url.pathExtension
    }

    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: self)
    }

    func addingPercentEncodingForQueryParameter() -> String {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    func toMarkdown() -> AttributedString {
        do {
            return try AttributedString(
                markdown: self,
                options: AttributedString.MarkdownParsingOptions(
                    allowsExtendedAttributes: true,
                    interpretedSyntax: .full
                )
            )
        } catch {
            print("Error parsing Markdown for string \(self): \(error)")
            return AttributedString(self)
        }
    }
}

public extension Optional where Wrapped == String {
    /// Return `true` only if it is not `nil` or empty.
    var isBlank: Bool {
        return self?.isEmpty ?? true
    }
}
