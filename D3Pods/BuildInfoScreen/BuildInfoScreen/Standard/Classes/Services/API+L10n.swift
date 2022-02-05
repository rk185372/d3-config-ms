//
//  API+L10n.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 8/29/19.
//

import Foundation
import Network

extension API {
    enum L10n {
        static func getL10n() -> Endpoint<Data> {
            return Endpoint(path: "v4/anon/l10n/bundle/mobile")
        }
    }
}
