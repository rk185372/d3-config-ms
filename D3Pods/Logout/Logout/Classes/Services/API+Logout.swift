//
//  API+Logout.swift
//  Logout
//
//  Created by Chris Carranza on 9/13/18.
//

import Foundation
import Network

extension API {
    enum Logout {
        static func logout() -> Endpoint<Void> {
            return Endpoint(path: "v3/auth/logout")
        }
    }
}
