//
//  SessionObserver.swift
//  D3 Banking
//
//  Created by Chris Carranza on 3/7/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import RxSwift
import Analytics
import Session

final class SessionObserver {
    private let bag = DisposeBag()
    
    init(analyticsTracker: AnalyticsTracker, userSession: UserSession) {

        userSession
            .rx
            .session
            .distinctUntilChanged()
            .subscribe(onNext: { session in
                if let session = session {
                    let profile = userSession.userProfiles[session.selectedProfileIndex]
                    analyticsTracker.setUserId(userId: "\(profile.loginId):\(session.startupKey)")
                } else {
                    analyticsTracker.setUserId(userId: nil)
                }
            })
            .disposed(by: bag)
    }
    
}
