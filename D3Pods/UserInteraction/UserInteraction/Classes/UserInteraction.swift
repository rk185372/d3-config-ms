//
//  UserInteraction.swift
//  UserInteraction
//
//  Created by Chris Carranza on 11/30/18.
//

import Foundation
import RxSwift
import RxRelay

public protocol UserInteraction: class {
    var userInteractions: Observable<Date> { get }
    func triggerUserInteraction()
}

public final class AppUserInteraction: UserInteraction {
    private let _syntheticEventRelay = BehaviorRelay(value: Date())
    private let bag = DisposeBag()
    
    public let userInteractions: Observable<Date>
    
    public init(touchEvents: Observable<UIEvent>) {
        
        userInteractions = Observable
            .merge(touchEvents.map { _ in Date() }, _syntheticEventRelay.asObservable())
            .share(replay: 1)
        
        // This is here to keep track of the interactions to ensure that
        // any new subscriptions are getting up to date information.
        userInteractions
            .subscribe()
            .disposed(by: bag)
    }
    
    public func triggerUserInteraction() {
        _syntheticEventRelay.accept(Date())
    }
}
