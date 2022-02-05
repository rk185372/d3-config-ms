//
//  OpenANewAccountResponse.swift
//  Accounts
//
//  Created by Branden Smith on 1/10/19.
//

import Foundation
import Utilities

public struct OpenANewAccountResponse: Decodable {
    public let status: NewAccountResponseStatus
    public let redirect: OpenANewAccountRedirect
}

public struct OpenANewAccountRedirect: Decodable {
    public let cookies: [String: Any]
    public let url: String
    public let method: String
    public let fields: [String: Any]

    enum CodingKeys: String, CodingKey {
        case cookies
        case url
        case method
        case fields
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cookies = try container.decode([String: Any].self, forKey: .cookies)
        url = try container.decode(String.self, forKey: .url)
        method = try container.decode(String.self, forKey: .method)
        fields = try container.decode([String: Any].self, forKey: .fields)
    }
}

public enum NewAccountResponseStatus: String, Codable {
    case ready
}
