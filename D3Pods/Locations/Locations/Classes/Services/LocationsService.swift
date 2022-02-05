//
//  LocationsService.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/19/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Network
import RxSwift

public protocol LocationsService {
    func getLocations(params: LocationSearchParams) -> Single<LocationsServiceResult>
}

public enum LocationsServiceResult {
    case success([Location])
    case failure(Error?)
}
