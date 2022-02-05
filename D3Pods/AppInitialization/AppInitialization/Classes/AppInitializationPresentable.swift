//
//  AppInitializationPresentable.swift
//  Pods
//
//  Created by Andrew Watt on 7/11/18.
//

import Foundation
import Utilities
import CompanyAttributes
import RxSwift
import Navigation

public final class AppInitializationPresentable {
    private let factory: AppInitializationViewControllerFactory
    private let bag = DisposeBag()
    
    public init(factory: AppInitializationViewControllerFactory) {
        self.factory = factory
    }
    
    public func createViewController(presentingFrom presenter: RootPresenter, suppressAutoPrompt: Bool) -> UIViewController {
        let viewController = factory.create()
        viewController.rx.state
            .asObservable()
            .filter { $0 == .completed }
            .take(1)
            .ignoreElements()
            .subscribe(onCompleted: {
                presenter.advance(from: .initializing(suppressAutoPrompt: suppressAutoPrompt))
            })
            .disposed(by: bag)
        return viewController
    }
}
