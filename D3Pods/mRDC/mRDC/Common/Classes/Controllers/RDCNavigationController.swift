//
//  RDCNavigationControllerViewController.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/9/18.
//

import CompanyAttributes
import ComponentKit
import Dip
import Session
import UIKit

final class RDCNavigationController: UINavigationControllerComponent {

    init(companyAttributesHolder: CompanyAttributesHolder,
         rdcHistoryViewController: RDCHistoryViewController,
         landingViewControllerFactory: RDCDepositLandingViewControllerFactory) {

        let viewController: UIViewController
        
        if companyAttributesHolder.companyAttributes.value?.boolValue(forKey: "dashboard.manage.deposit.history.enabled") ?? false {
            viewController = rdcHistoryViewController
        } else {
            viewController = landingViewControllerFactory.create()
        }

        super.init(rootViewController: viewController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
