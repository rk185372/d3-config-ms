//
//  SettingsResponse.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/18/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import Utilities

struct SettingsResponse: Decodable {
    let resources: [String: Any]
    let settings: [String: Any]

    enum CodingKeys: String, CodingKey {
        case resources
        case settings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        resources = try container.decode([String: Any].self, forKey: .resources)
        settings = try container.decode([String: Any].self, forKey: .settings)
    }
}
