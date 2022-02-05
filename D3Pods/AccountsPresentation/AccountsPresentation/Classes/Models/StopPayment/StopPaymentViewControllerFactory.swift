//
//  StopPaymentViewControllerFactory.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 5/11/18.
//

import Foundation
import D3Accounts
import ComponentKit
import Localization

final class StopPaymentViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private let serviceItem: AccountsService
    private let stopSinglePaymentViewControllerFactory: StopSinglePaymentViewControllerFactory
    private let stopRangeOfPaymentsViewControllerFactory: StopRangeOfPaymentsViewControllerFactory
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         serviceItem: AccountsService,
         stopSinglePaymentViewControllerFactory: StopSinglePaymentViewControllerFactory,
         stopRangeOfPaymentsViewControllerFactory: StopRangeOfPaymentsViewControllerFactory) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.serviceItem = serviceItem
        self.stopSinglePaymentViewControllerFactory = stopSinglePaymentViewControllerFactory
        self.stopRangeOfPaymentsViewControllerFactory = stopRangeOfPaymentsViewControllerFactory
    }
    
    func create(account: Account) -> StopPaymentViewController {
        return StopPaymentViewController(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            account: account,
            serviceItem: serviceItem,
            stopSinglePaymentViewControllerFactory: stopSinglePaymentViewControllerFactory,
            stopRangeOfPaymentsViewControllerFactory: stopRangeOfPaymentsViewControllerFactory
        )
    }
}
