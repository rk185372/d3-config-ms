//
//  API+AppInitialization.swift
//  Accounts
//
//  Created by Branden Smith on 6/18/18.
//

import Foundation
import Network
import Utilities

extension API {
    enum AppInitialization {
        static func loadAppConfiguration() -> Endpoint<Data> {
            return Endpoint(path: "v3/startup/ui")
        }

        static func updateAppConfiguration() -> Endpoint<Data> {
            return Endpoint(path: "v3/startup/ui/authenticated")
        }
        
        static func upgradeCheck(device: Device) -> Endpoint<UpgradeCheckResponse> {
            return Endpoint(method: .get, path: "v3/startup/mobile-initialization", parameters: device.dictionary())
        }
    }
}
