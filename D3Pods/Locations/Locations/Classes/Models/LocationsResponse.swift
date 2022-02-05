//
//  LocationsResponse.swift
//  Accounts
//
//  Created by Branden Smith on 10/25/18.
//

import Foundation

public enum LocationsResponse {
    case none
    case success([Location])
    case failure
}
