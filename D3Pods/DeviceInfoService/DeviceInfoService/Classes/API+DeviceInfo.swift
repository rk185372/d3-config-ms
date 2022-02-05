//
//  API+DeviceInfo.swift
//  DeviceInfoService
//
//  Created by Chris Carranza on 8/15/18.
//

import Foundation
import Network

extension API {
    enum DeviceInfo {
        static func getDeviceInfoUnauthenticated(uuid: String) -> Endpoint<DeviceInfoResponse> {
            return Endpoint(method: .get, path: "v3/devices/\(uuid)/find-uuid-with-auth-token")
        }
        
        static func getDeviceInfo(uuid: String) -> Endpoint<DeviceInfoResponse> {
            return Endpoint(method: .get, path: "v3/devices/\(uuid)/uuid")
        }
    }
}
