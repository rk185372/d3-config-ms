//
//  LocationsServiceMock.swift
//  D3 BankingTests
//
//  Created by Branden Smith on 11/29/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import CoreLocation
import Foundation
import Utilities
import Network

@testable import D3_N3xt
@testable import Locations

final class LocationsServiceMock: LocationsService {
    func getLocations(withCompletion completion: @escaping(Result<[Location]>) -> Void) {
        completion(.success(testLocations))
    }

    let testLocations: [Location] = [
        .init(
            locationType: .atm,
            name: "D3 Banking ATM",
            address: LocationAddress(
                street: "4705 N 163rd St",
                city: "Omaha",
                state: "NE",
                zip: 68116
            ),
            phoneNumber: 4023217875,
            distanceDescription: "1.5 Mi",
            todaysSchedule: "11:00am - 5:00pm",
            fullSchedule: "",
            coordinate: CLLocationCoordinate2D(latitude: 41.252363, longitude: -95.997988)
        ),
        .init(
            locationType: .bank,
            name: "D3 Banking Branch",
            address: LocationAddress(
                street: "4705 N 163rd St",
                city: "Omaha",
                state: "NE",
                zip: 68116
            ),
            phoneNumber: 4023217875,
            distanceDescription: "2.5 Mi",
            todaysSchedule: "11:00am - 5:00pm",
            fullSchedule: "",
            coordinate: CLLocationCoordinate2D(latitude: 41.243058, longitude: -96.005487)
        )
    ]
}
