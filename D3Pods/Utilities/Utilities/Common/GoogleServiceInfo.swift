//
//  GoogleServiceInfo.swift
//  D3 Banking
//
//  Created by Elvin Bearden on 5/31/21.
//

import Foundation

public struct GoogleServiceInfo: Codable {
    public static let shared = GoogleServiceInfo()
    public let apiKey: String

    enum CodingKeys: String, CodingKey {
        case apiKey = "API_KEY"
    }

    init() {
        guard let configPath = Bundle.main
                                .url(forResource: "GoogleService-Info", withExtension: "plist") else {
            fatalError("Missing GoogleService-Info plist")
        }

        let decoder = PropertyListDecoder()
        let url = configPath
        let contents = try! Data(contentsOf: url)

        self = try! decoder.decode(GoogleServiceInfo.self, from: contents)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.apiKey = try container.decode(String.self, forKey: .apiKey)
    }
}
