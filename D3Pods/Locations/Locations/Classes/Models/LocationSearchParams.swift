//
//  LocationSearchParams.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/20/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import MapKit
import Utilities

public struct LocationSearchParams {
    public var coordinate: CLLocationCoordinate2D?
    public var radius = SearchRadius.threeMiles
    public var address: String?
    public var type = SearchScope.all

    public init() {}

    public init(coordinate: CLLocationCoordinate2D? = nil,
                radius: SearchRadius = .threeMiles,
                address: String? = nil,
                type: SearchScope = .branch) {
        self.coordinate = coordinate
        self.radius = radius
        self.address = address
        self.type = type
    }
    
    public func dictionary() -> [String: Any] {
        let values: [String: Any?] = [
            "latitude": coordinate?.latitude,
            "longitude": coordinate?.longitude,
            "distance": radius.rawValue,
            "address": address,
            "type": type.rawValue
        ]
        return values.compactMapValues()
    }
}

public enum SearchScope: String {
    case branch = "BRANCH"
    case atm = "ATM"
    case all = "ALL"
    case empty = "EMPTY"
    
    public var l10nKey: String {
        switch self {
        case .branch:
            return "launchPage.geolocation.filter.branches"
        case .all:
            return "launchPage.geolocation.filter.allLocations"
        case .atm:
            return "launchPage.geolocation.filter.atms"
        case .empty:
            return ""
        }
    }
}
