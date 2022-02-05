//
//  API+Enablement.swift
//  Enablement
//
//  Created by Chris Carranza on 5/22/18.
//

import Foundation
import Network

extension API {
    enum Enablement {
        static func enableQuickView(deviceId: Int, headers: [String: String]?) -> Endpoint<EnableResponse> {
            return Endpoint(.init(method: .post, path: "v3/devices/\(deviceId)/snapshot", headers: headers))
        }
    }
}
