//
//  API+LegalContent.swift
//  LegalContent
//
//  Created by Chris Carranza on 5/22/18.
//

import Foundation
import Network

public extension API {
    enum LegalContent {
        public static func retreiveDisclosure(legalServiceType: LegalServiceType) -> Endpoint<DisclosureResponse> {
            return Endpoint(method: .get, path: "v3/content/legal/\(legalServiceType.rawValue)/disclosure")
        }
    }
}
