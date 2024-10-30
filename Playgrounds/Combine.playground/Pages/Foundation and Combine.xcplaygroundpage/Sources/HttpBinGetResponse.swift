public struct HttpBinGetResponse: Decodable {
    let headers: Headers
}

struct Headers: Decodable {
    let userAgent: String

    enum CodingKeys: String, CodingKey {
        case userAgent = "User-Agent"
    }
}
