//
//  API+Session.swift
//  Session
//
//  Created by Andrew Watt on 7/6/18.
//

import Foundation
import Network
import Utilities

extension API {
    enum Session {
        static func session(device: Device, tokenHandler: PushNotificationTokenHandler) -> Endpoint<RawSession> {
            var paramsDict = device.dictionary()

            if let pushId = tokenHandler.pushId {
                paramsDict["pushId"] = pushId
            }
            
            return Endpoint(method: .get, path: "v3/auth/session", parameters: paramsDict)
        }
    }
}
