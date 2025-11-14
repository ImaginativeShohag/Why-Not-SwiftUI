//
//  Copyright © 2025 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation
import UIKit

public struct IdentifiableImage: Identifiable {
    public let id = UUID()
    public let image: UIImage
}

public extension UIImage {
    func toIdentifiable() -> IdentifiableImage {
        IdentifiableImage(image: self)
    }
}
