//
//  NotificationListener.swift
//  D3 Banking
//
//  Created by Andrew Watt on 7/26/18.
//

import Foundation
import Logging
import RxSwift
import RxRelay
import Utilities
import Session
import Navigation
import WebKit

public final class NotificationListener {
    private let bag = DisposeBag()

    public init(presenter: RootPresenter, userSession: UserSession) {

        NotificationCenter.default.rx.notification(.loggedOut)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (notification) in
                log.debug("Reacting to \(notification.name)")
                userSession.rawSession = nil
                
                WKWebsiteDataStore.default().deleteSessionCookie()
            })
            .disposed(by: bag)

        NotificationCenter.default.rx.notification(.sessionExpired)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (notification) in
                log.debug("Reacting to \(notification.name)")
                userSession.rawSession = nil
                WKWebsiteDataStore.default().deleteSessionCookie()
            })
            .disposed(by: bag)
        
        NotificationCenter.default.rx.notification(.maintenance)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (notification) in
                log.debug("Reacting to \(notification.name)")
                let message = notification.userInfo?["message"] as? String
                presenter.present(view: .maintenance(message: message))
            })
            .disposed(by: bag)

        NotificationCenter.default.rx.notification(.unauthenticated)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (notification) in
                log.debug("Reacting to \(notification.name)")
                userSession.rawSession = nil
                WKWebsiteDataStore.default().deleteSessionCookie()
            })
            .disposed(by: bag)
    }
}
