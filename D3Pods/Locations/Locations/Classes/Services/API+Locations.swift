//
//  API+Locations.swift
//  Accounts
//
//  Created by Chris Carranza on 1/16/18.
//

import Foundation
import Network

extension API {
    enum Locations {
        static func locations(params: LocationSearchParams) -> Endpoint<LocationSearchResult> {
            return Endpoint(method: .get, path: "v3/location", parameters: params.dictionary())
        }
    }
}

struct LocationSearchResult: Decodable {
    var locationsInRadius: [RawLocation]
}
