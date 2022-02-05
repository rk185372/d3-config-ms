//
//  LocationsViewModel.swift
//  Locations
//
//  Created by Andrew Watt on 7/24/18.
//

import Foundation
import Logging
import RxSwift
import RxRelay
import Utilities

public final class LocationsViewModel {
    private let searchParamDebounceInterval: DispatchTimeInterval = .milliseconds(500)
    private let bag = DisposeBag()
    
    public let searchParams = BehaviorRelay(value: LocationSearchParams())
    public let locations = BehaviorRelay<LocationsServiceResult>(value: .success([]))
    
    public init(service: LocationsService) {
        searchParams.asObservable()
            .debounce(searchParamDebounceInterval, scheduler: SerialDispatchQueueScheduler(qos: .default))
            .flatMapLatest { (params) -> Single<LocationsServiceResult> in
                if (params.isValid) {
                    return service.getLocations(params: params)
                } else {
                    return Single.create { _ in
                        return Disposables.create()
                    }
                }
            }
            .bind(to: locations)
            .disposed(by: bag)
    }
}

private extension LocationSearchParams {
    var isValid: Bool {
        return coordinate != nil || !(address?.isEmpty ?? true)
    }
}
