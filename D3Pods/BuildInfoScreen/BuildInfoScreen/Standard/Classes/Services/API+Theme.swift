//
//  API+Theme.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 8/19/19.
//

import Foundation
import Network

extension API {
    enum Theme {
        static func getTheme() -> Endpoint<Data> {
            return Endpoint(method: .get, path: "v4/themes/IOS", parameters: ["overrides": true])
        }
    }
}
