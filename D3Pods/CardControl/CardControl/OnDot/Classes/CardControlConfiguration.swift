//
//  CardControlConfiguration.swift
//  CardControl
//
//  Created by Elvin Bearden on 5/24/21.
//

import Foundation
import CompanyAttributes
import Utilities
import RxSwift

public struct CardControlConfiguration: Decodable {
    let appToken: String
    let fiToken: String
    let googleApiKey: String
    let deploymentToken: String
    let endpoint: String
//    let publicKeys: [URL]

    enum CodingKeys: String, CodingKey {
        case appToken
        case fiToken
        case deploymentToken
        case endpoint
//        case publicKeys
    }

    init() {
        guard let configPath = CardControlBundle
                                .bundle
                                .url(forResource: "OnDotProperties", withExtension: "json") else {
            fatalError("Missing config file for OnDot.")
        }
        
        let decoder = JSONDecoder()
        let url = configPath
        let contents = try! Data(contentsOf: url)
        
        self = try! decoder.decode(CardControlConfiguration.self, from: contents)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.appToken = try container.decode(String.self, forKey: .appToken)
        self.fiToken = try container.decode(String.self, forKey: .fiToken)
        self.googleApiKey = GoogleServiceInfo.shared.apiKey
        self.deploymentToken = try container.decode(String.self, forKey: .deploymentToken)
        self.endpoint = try container.decode(String.self, forKey: .endpoint)
//        self.publicKeys = try container.decode([URL].self, forKey: .publicKeys)

    }
}
