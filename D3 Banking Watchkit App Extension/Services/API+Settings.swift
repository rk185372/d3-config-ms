//
//  API+Settings.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/18/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import Network

extension API {
    enum WatchSettings {
        static func getSettings() -> Endpoint<SettingsResponse> {
            return Endpoint(path: "v3/startup/watch")
        }
    }
}
