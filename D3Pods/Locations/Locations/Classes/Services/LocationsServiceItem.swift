//
//  LocationsServiceItem.swift
//  Accounts
//
//  Created by Branden Smith on 11/29/17.
//

import Foundation
import Network
import RxSwift

public final class LocationsServiceItem: LocationsService {
    
    private let client: ClientProtocol
    
    public init(client: ClientProtocol) {
        self.client = client
    }

    public func getLocations(params: LocationSearchParams) -> Single<LocationsServiceResult> {
        return client
            .request(API.Locations.locations(params: params))
            .map({ result in
                return .success(result.locationsInRadius.compactMap(Location.init(from:)))
            }).catchError { error in
                return Single.just(.failure(error))
            }
    }
}
