//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Moya

extension MultipartFormData {
    public var debugDescription: String {
        var description = "MultipartFormData:"
        description += "\nName: \(name)"
        
        switch provider {
        case .data(let dataValue):
            description += "\nProvider: .data: \(String(data: dataValue, encoding: .utf8) ?? "")"
            
        case .file(let url):
            description += "\nProvider: .file: \(url)"
            
        case .stream:
            description += "\nProvider: .stream: \(provider)"
        }
        
        if let fileName = fileName {
            description += "\nFileName: \(fileName)"
        }
        
        if let mimeType = mimeType {
            description += "\nMimeType: \(mimeType)"
        }
        
        return description
    }
}

public extension Array where Element == MultipartFormData {
    func getDebugDescription() -> String {
        var debugDescription = "[MultipartFormData]:"
        
        for item in self {
            var description = ""
            
            description += "\nName: \(item.name)"
            
            switch item.provider {
            case .data(let dataValue):
                description += ", Provider: .data: \(String(data: dataValue, encoding: .utf8) ?? "")"
                
            case .file(let url):
                description += ", Provider: .file: \(url)"
                
            case .stream:
                description += ", Provider: .stream: \(item.provider)"
            }
            
            if let fileName = item.fileName {
                description += ", FileName: \(fileName)"
            }
            
            if let mimeType = item.mimeType {
                description += ", MimeType: \(mimeType)"
            }
            
            debugDescription += description
        }
        
        return debugDescription
    }
}
