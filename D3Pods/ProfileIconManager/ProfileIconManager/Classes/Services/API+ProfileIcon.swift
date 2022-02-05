//
//  API+ProfileIcon.swift
//  ProfileIconManager
//
//  Created by Pablo Pellegrino on 1/26/22.
//

import Foundation
import Network
import UIKit

public extension API {
    enum ProfileIcon {
        public static func getCurrent() -> Endpoint<Data> {
            return Endpoint(method: .get, path: "v4/personalization/avatars/current")
        }
    }
}
