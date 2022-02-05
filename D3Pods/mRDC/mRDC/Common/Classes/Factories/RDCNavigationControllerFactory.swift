//
//  RDCNavigationControllerFactory.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/9/18.
//

import CompanyAttributes
import ComponentKit
import Dip
import Foundation
import InAppRatingApi
import Localization
import Permissions
import Utilities

public final class RDCNavigationControllerFactory: ViewControllerFactory {
    private let companyAttributesHolder: CompanyAttributesHolder
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let rdcHistoryViewModel: RDCHistoryViewModel
    private let rdcDepositTransactionDetailViewControllerFactory: RDCDepositTransactionDetailViewControllerFactory
    private let depositViewControllerFactory: RDCDepositViewControllerFactory
    private let inAppRatingManager: InAppRatingManager

    init(companyAttributesHolder: CompanyAttributesHolder,
         l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         rdcHistoryViewModel: RDCHistoryViewModel,
         rdcDepositTransactionDetailViewControllerFactory: RDCDepositTransactionDetailViewControllerFactory,
         depositViewControllerFactory: RDCDepositViewControllerFactory,
         inAppRatingManager: InAppRatingManager) {
        self.companyAttributesHolder = companyAttributesHolder
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.rdcHistoryViewModel = rdcHistoryViewModel
        self.rdcDepositTransactionDetailViewControllerFactory = rdcDepositTransactionDetailViewControllerFactory
        self.depositViewControllerFactory = depositViewControllerFactory
        self.inAppRatingManager = inAppRatingManager
    }

    public func create() -> UIViewController {
        // Warning: The RDCHistoryViewController and the RDCDepositLandingViewControllerFactory
        // should be created here and not passed in via the dependency container. If they are passed in
        // and held onto by this factory they will never be deallocated.
        // The reason for this is that there would be a chain of pointers as follows:
        // RootPresenter (singleton never gets deallocated) -> RootViewControllerPresenter -> DashboardPresentable ->
        // DashboardViewControllerFactory -> NavigationItemViewControllerFactory -> RDCNavigationControllerFactory ->
        // RDCHistoryViewController and RDCDepositLandingViewControllerFactory
        let rdcHistoryViewController = RDCHistoryViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            rdcHistoryViewModel: rdcHistoryViewModel,
            rdcDepositTransactionDetailViewControllerFactory: rdcDepositTransactionDetailViewControllerFactory,
            depositViewControllerFactory: depositViewControllerFactory,
            inAppRatingManager: inAppRatingManager
        )

        let landingViewControllerFactory = RDCDepositLandingViewControllerFactory(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            depositViewControllerFactory: depositViewControllerFactory,
            inAppRatingManager: inAppRatingManager
        )

        return RDCNavigationController(
            companyAttributesHolder: companyAttributesHolder,
            rdcHistoryViewController: rdcHistoryViewController,
            landingViewControllerFactory: landingViewControllerFactory
        )
    }
}

extension RDCNavigationControllerFactory: Permissioned {
    public var feature: Feature {
        return .mrdc
    }
}
