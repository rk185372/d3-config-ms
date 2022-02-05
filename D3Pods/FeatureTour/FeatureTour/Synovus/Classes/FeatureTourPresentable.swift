//
//  FeatureTourPresentable.swift
//  FeatureTour
//
//  Created by Chris Carranza on 1/16/19.
//

import Foundation
import Navigation
import RxSwift
import RxCocoa

public final class FeatureTourPresentable {
    private let bag = DisposeBag()
    
    private let featureTourContainerViewControllerFactory: FeatureTourContainerViewControllerFactory
    private let featureTourContent: FeatureTourContent
    
    init(featureTourContainerViewControllerFactory: FeatureTourContainerViewControllerFactory, featureTourContent: FeatureTourContent) {
        self.featureTourContainerViewControllerFactory = featureTourContainerViewControllerFactory
        self.featureTourContent = featureTourContent
    }
    
    public func createViewController(presentingFrom presenter: RootPresenter, suppressAutoPrompt: Bool) -> UIViewController? {
        guard featureTourContent.hasContent else { return nil }
        
        let viewController = featureTourContainerViewControllerFactory.create() as! FeatureTourContainerViewController
        viewController
            .rx
            .featureTourCompleted
            .take(1)
            .ignoreElements()
            .subscribe(onCompleted: {
                presenter.advance(from: .featureTour(suppressAutoPrompt: suppressAutoPrompt))
            })
            .disposed(by: bag)
        return viewController
    }
}
