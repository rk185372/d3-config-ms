//
//  WebError.swift
//  Web
//
//  Created by Andrew Watt on 7/2/18.
//

import Foundation

public enum WebError: Error, CustomStringConvertible {
    case invalidBaseUrl
    case invalidOrMissingScriptParameter(name: String)
    case json
    case localFileNotFound(filename: String)
    case missingSession

    public var description: String {
        switch self {
        case .invalidBaseUrl:
            return "Invalid base URL"
        case .invalidOrMissingScriptParameter(let name):
            return "Invalid or missing script parameter: \(name)"
        case .json:
            return "Unable to encode required JSON"
        case .localFileNotFound(let filename):
            return "Missing local file \(filename)"
        case .missingSession:
            return "User session missing"
        }
    }
}
