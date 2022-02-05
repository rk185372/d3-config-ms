//
//  LogoutHandler.swift
//  Logout
//
//  Created by Chris Carranza on 9/17/18.
//

import Foundation
import Session
import Navigation
import RxSwift

/// Listens for the session to be destroyed in order
/// to perform the logout process.
public final class LogoutHandler {
    private let bag = DisposeBag()
    
    public init(session: UserSession, presenter: RootPresenter) {
        // We want to skip the initial nil value to avoid
        // trying 'logout' when first subscribing.
        session
            .rx
            .session
            .distinctUntilChanged()
            .skip(1)
            .filter { $0 == nil }
            .subscribe(onNext: { _ in
                presenter.present(view: .loggingOut)
            })
            .disposed(by: bag)
    }
}
