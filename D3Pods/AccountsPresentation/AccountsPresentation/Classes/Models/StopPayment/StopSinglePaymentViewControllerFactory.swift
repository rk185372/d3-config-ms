//
//  StopSinglePaymentViewControllerFactory.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 5/11/18.
//

import Foundation
import D3Accounts

final class StopSinglePaymentViewControllerFactory {
    private let serviceItem: AccountsService
    private let buttonPresenterFactory: ButtonPresenterFactory
    
    init(serviceItem: AccountsService, buttonPresenterFactory: ButtonPresenterFactory) {
        self.serviceItem = serviceItem
        self.buttonPresenterFactory = buttonPresenterFactory
    }
    
    func create(stoppedPayment: StoppedPayment,
                account: Account,
                delegate: StopSinglePaymentViewControllerDelegate) -> StopSinglePaymentViewController {
        return StopSinglePaymentViewController(
            stoppedPayment: stoppedPayment,
            account: account,
            serviceItem: serviceItem,
            delegate: delegate,
            buttonPresenterFactory: buttonPresenterFactory
        )
    }
}
