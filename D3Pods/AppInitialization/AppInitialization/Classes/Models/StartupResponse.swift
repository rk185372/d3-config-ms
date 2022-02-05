//
//  StartupResponse.swift
//  AppInitialization
//
//  Created by Andrew Watt on 8/7/18.
//

import Foundation
import Utilities

struct StartupResponse: Decodable {
    let settings: [String: Any]
    
    enum CodingKeys: String, CodingKey {
        case settings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        settings = try container.decode([String: Any].self, forKey: .settings)
    }
}
