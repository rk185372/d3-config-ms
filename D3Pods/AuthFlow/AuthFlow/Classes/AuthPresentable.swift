//
//  AuthPresentable.swift
//  AuthFlow
//
//  Created by Andrew Watt on 7/11/18.
//

import Foundation
import Utilities
import RxSwift
import Session
import Navigation

public final class AuthPresentable {
    private let factory: AuthFlowNavigationControllerFactory
    private let sessionService: SessionService
    private let bag = DisposeBag()
    
    public init(factory: AuthFlowNavigationControllerFactory, sessionService: SessionService) {
        self.factory = factory
        self.sessionService = sessionService
    }
    
    public func createViewController(presentingFrom presenter: RootPresenter, suppressAutoPrompt: Bool) -> UIViewController {
        let viewController = factory.create(suppressAutoPrompt: suppressAutoPrompt)
        viewController.rx.authenticated
            .asObservable()
            .filter { $0 }
            .take(1)
            .asSingle()
            .subscribe(onSuccess: { _ in
                presenter.advance(from: .authenticating(suppressAutoPrompt: suppressAutoPrompt))
            })
            .disposed(by: bag)
        return viewController
    }
}
