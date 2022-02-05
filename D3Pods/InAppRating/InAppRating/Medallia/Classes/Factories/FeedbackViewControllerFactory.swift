//
//  FeedbackViewControllerFactory.swift
//  InAppRating
//
//  Created by Jose Torres on 7/27/20.
//

import Foundation
import Utilities
import CompanyAttributes
import ComponentKit
import Logging
import RxSwift
import Permissions
import MedalliaDigitalSDK

extension NotPresentViewController.ActionKey {
    static let medalliaDigitalSDK = NotPresentViewController.ActionKey("medalliaDigitalSDK")
}

public final class FeedbackViewControllerFactory: ViewControllerFactory {
    
    private var companyAttributesHolder: CompanyAttributesHolder
    private let bag = DisposeBag()
        
    public init(companyAttributesHolder: CompanyAttributesHolder) {
        self.companyAttributesHolder = companyAttributesHolder
    }
    
    public func create() -> UIViewController {        
        let dummyViewController = NotPresentViewController(actionKey: .medalliaDigitalSDK)
        dummyViewController.view.backgroundColor = .white
        return dummyViewController
    }
}

extension FeedbackViewControllerFactory: Permissioned {
    public var feature: Feature {
        return .feedback
    }
}
