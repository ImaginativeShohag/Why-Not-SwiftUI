//
//  Copyright © 2024 Md. Mahmudul Hasan Shohag. All rights reserved.
//

import Foundation

/// A collection of human-readable HTTP status code abbreviation.
/// This enum will be used for calling ``getMessage(for:)`` method.
public enum HttpStatusCode {
    private static let httpStatusCodes: [Int: String] = [
        100: "Continue.\nThe server has received the initial part of the request, and the client should proceed with the rest of the request.",
        101: "Switching Protocols: The server agrees to switch protocols and has upgraded the connection.",
        102: "Processing.\nThe server is still processing the request and will return a response once it's completed.",
        200: "OK. The request has succeeded and the server returned the requested data.",
        201: "Created. The request has been fulfilled, and a new resource has been created.",
        202: "Accepted. The request has been accepted for processing but has not been completed yet.",
        203: "Non-Authoritative Information: The server successfully processed the request but is returning information from a different source.",
        204: "No Content. The server successfully processed the request but does not need to return any content.",
        205: "Reset Content. The server requires the requester to reset the document view, typically done by clearing the form.",
        206: "Partial Content. The server is delivering only part of the resource due to a range header sent by the client.",
        300: "Multiple Choices. The requested resource has multiple choices, each with its own URI, and the client should choose one.",
        301: "Moved Permanently. The requested resource has been permanently moved to a new location.",
        302: "Found.\nThe requested resource has been temporarily moved to a different location.",
        303: "See Other: The response to the request can be found under a different URI, and the client should retrieve it using a GET method on that resource.",
        304: "Not Modified.\nThe client's cached version of the requested resource is still valid, and no new data needs to be sent.",
        307: "Temporary Redirect. The requested resource has been temporarily moved to a different location.",
        308: "Permanent Redirect. The requested resource has been permanently moved to a different location.",
        400: "Your session has expired! Please try again to login.",
        401: "Unauthorized! Your session has expired. Please login again to continue.",
        402: "Payment Required! The server requires payment to fulfill the request.",
        403: "Access Denied!",
        404: "Not Found! The server could not find the requested resource.",
        405: "Method Not Allowed! The method specified in the request is not allowed for the resource.",
        406: "Not Acceptable. The server cannot produce a response matching the list of acceptable values defined in the request's headers.",
        407: "Proxy Authentication Required. The client must authenticate itself with the proxy server.",
        408: "Request Timeout! The server timed out waiting for the request.",
        409: "Conflict!\nThe request could not be completed due to a conflict with the current state of the target resource.",
        410: "Gone: The requested resource is no longer available and will not be available again.",
        411: "Length Required: The server requires the request to be valid with a defined Content-Length header.",
        412: "Precondition Failed: The server does not meet the preconditions specified by the client.",
        413: "Payload Too Large: The request is larger than the server is willing or able to process.",
        414: "URI Too Long: The URI provided in the request is too long for the server to process.",
        415: "Unsupported Media Type: The server does not support the media type provided in the request.",
        416: "Range Not Satisfiable: The requested range cannot be fulfilled.",
        417: "Expectation Failed: The server cannot meet the requirements of the Expect request-header field.",
        418: "I'm a teapot. The server refuses to brew coffee because it is, in fact, a teapot.",
        422: "Unprocessable Entity! The request was well-formed but unable to be followed due to semantic errors.",
        429: "Too Many Requests. The user has sent too many requests in a given amount of time.",
        431: "Request Header Fields Too Large! The server is unwilling to process the request because the request header fields are too large.",
        500: "Internal Server Error. Please try again.",
        501: "Not Implemented! The server does not support the functionality required to fulfill the request.",
        502: "Bad Gateway: The server received an invalid response from an upstream server while acting as a gateway or proxy.",
        503: "Service Unavailable! The server is currently unable to handle the request due to a temporary overload or maintenance.",
        504: "Gateway Timeout: The server did not receive a timely response from an upstream server while acting as a gateway or proxy.",
        505: "HTTP Version Not Supported: The server does not support the HTTP protocol version used in the request.",
        511: "Network Authentication Required.\nThe client needs to authenticate to gain network access.",
        -1: "Please check your connection and try again!"
    ]

    /// This method will be used for getting human-readable message for HTTP status code.
    /// - Parameters:
    ///    - Code : `HTTP` status code.
    /// - Returns: The respective message representation for given status code.
    public static func getMessage(for code: Int) -> String {
        return httpStatusCodes[code] ?? "Something went wrong. Please try again!"
    }
}
