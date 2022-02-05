//
//  WatchLocationsViewModel.swift
//  Accounts
//
//  Created by Branden Smith on 10/25/18.
//

import Foundation
import Logging
import RxSwift
import RxRelay
import Utilities

public final class WatchLocationsViewModel {
    private let searchParamDebounceInterval: DispatchTimeInterval = .milliseconds(500)
    private let bag = DisposeBag()

    public let searchParams: BehaviorRelay<LocationSearchParams?>
    public let locations: BehaviorRelay<LocationsResponse>

    public init(service: LocationsService, searchParams: LocationSearchParams? = nil, locationsResponse: LocationsResponse = .none) {
        self.searchParams = BehaviorRelay(value: searchParams)
        self.locations = BehaviorRelay(value: locationsResponse)

        self.searchParams.asObservable()
            .debounce(searchParamDebounceInterval, scheduler: SerialDispatchQueueScheduler(qos: .default))
            .skipNil()
            .flatMapLatest { (params) -> Single<LocationsServiceResult> in
                return service.getLocations(params: params)
            }
            .map { serviceResult -> LocationsResponse in
                switch serviceResult {
                case .success(let locations):
                    return .success(locations)
                case .failure:
                    return .failure
                }
            }
            .bind(to: locations)
            .disposed(by: bag)
    }
}
