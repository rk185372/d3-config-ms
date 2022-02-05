//
//  SessionExpirationManagerFactory.swift
//  SessionExpiration
//
//  Created by Chris Carranza on 12/11/18.
//

import Foundation
import UserInteraction
import RxSwift
import CompanyAttributes

final class SessionExpirationManagerFactory {
    private let userInteraction: UserInteraction
    private let companyAttributes: CompanyAttributesHolder
    private let scheduler: SchedulerType
    
    init(userInteraction: UserInteraction, companyAttributes: CompanyAttributesHolder, scheduler: SchedulerType = MainScheduler.instance) {
        self.userInteraction = userInteraction
        self.companyAttributes = companyAttributes
        self.scheduler = scheduler
    }
    
    func create() -> SessionExpirationManager {
        let timeout = companyAttributes
            .companyAttributes
            .value?
            .intValue(forKey: "consumerAuthentication.session.inactivity.minutes") ?? 15
        
        return SessionExpirationManager(
            timeout: TimeInterval(timeout * 60),
            touchObservable: userInteraction.userInteractions,
            scheduler: scheduler
        )
    }
}
