//
//  MaintenancePresentable.swift
//  Maintenance
//
//  Created by Andrew Watt on 8/3/18.
//

import Foundation
import Navigation
import RxSwift
import RxRelay

public final class MaintenancePresentable {
    private let factory: MaintenanceViewControllerFactory
    
    private let bag = DisposeBag()
    
    public init(factory: MaintenanceViewControllerFactory) {
        self.factory = factory
    }

    public func createViewController(presentingFrom presenter: RootPresenter, withMessage message: String?) -> UIViewController {
        let viewController = factory.create()
        viewController.loadViewIfNeeded()
        if let message = message {
            viewController.message = message
        }
        
        NotificationCenter.default.rx.notification(UIApplication.didBecomeActiveNotification)
            .takeUntil(viewController.rx.deallocated)
            .subscribe(onNext: { (_) in
                presenter.present(view: .initializing(suppressAutoPrompt: false))
            })
            .disposed(by: bag)
        
        return viewController
    }
}
