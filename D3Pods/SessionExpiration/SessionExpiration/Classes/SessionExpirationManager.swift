//
//  SessionExpirationManager.swift
//  D3 Banking
//
//  Created by Branden Smith on 8/28/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import CompanyAttributes
import Foundation
import RxRelay
import RxSwift
import Session
import Utilities
import UserInteraction

final class SessionExpirationManager {

    private(set) var timeoutState: Observable<State>!
    private let _touchInterceptionEnabled: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    private let bag = DisposeBag()

    var touchInterceptionEnabled: Bool {
        get { return _touchInterceptionEnabled.value }
        set { _touchInterceptionEnabled.accept(newValue) }
    }

    init(timeout: TimeInterval,
         touchObservable: Observable<Date>,
         scheduler: SchedulerType) {
        
        let timer = Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: scheduler)
        
        let userTouches = Observable
            .combineLatest(touchObservable, _touchInterceptionEnabled.asObservable())
            .filter { $0.1 }
            .map { $0.0 }

        let trigger = Observable
            .combineLatest(timer, userTouches)
            .distinctUntilChanged { (old, new) -> Bool in
                return old.0 == new.0
            }
            .map { $0.1 }
        
        timeoutState = trigger
            .map { lastActivityDate in
                let currentDate = scheduler.now
                
                if currentDate.timeIntervalSince(lastActivityDate) > timeout {
                    return .timeout
                } else if currentDate > lastActivityDate
                    .addingTimeInterval(timeout)
                    .addingTimeInterval(-120.0) {
                    var intervalToTimeout = lastActivityDate
                        .addingTimeInterval(timeout)
                        .timeIntervalSince(currentDate)
                    intervalToTimeout.round(.up)
                    
                    return .warning(secondsRemaining: Int(intervalToTimeout))
                } else {
                    return .clear
                }
            }
            .distinctUntilChanged()
    }
}

extension SessionExpirationManager {
    enum State {
        case clear
        case warning(secondsRemaining: Int)
        case timeout
    }
}

extension SessionExpirationManager.State: Equatable {
    static func == (lhs: SessionExpirationManager.State, rhs: SessionExpirationManager.State) -> Bool {
        switch (lhs, rhs) {
        case (.clear, .clear):
            return true
        case (.timeout, .timeout):
            return true
        case (.warning(let leftSecondsRemaining), .warning(let rightSecondsRemaining)):
            return leftSecondsRemaining == rightSecondsRemaining
        default:
            return false
        }
    }
}
