//
//  LogoutPresentable.swift
//  Logout
//
//  Created by Chris Carranza on 9/13/18.
//

import Foundation
import Navigation
import RxSwift

public final class LogoutPresentable {
    private let factory: LogoutViewControllerFactory
    
    private let bag = DisposeBag()
    
    public init(logoutFactory: LogoutViewControllerFactory) {
        self.factory = logoutFactory
    }
    
    public func createViewController(presentingFrom presenter: RootPresenter) -> UIViewController {
        let viewController = factory.create()
        
        viewController
            .logoutComplete
            .subscribe(onCompleted: {
                presenter.present(view: .initializing(suppressAutoPrompt: true))
            })
            .disposed(by: bag)
        
        return viewController
    }
}
