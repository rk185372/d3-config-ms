//
//  StopRangeOfPaymentsViewControllerFactory.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 5/11/18.
//

import Foundation
import D3Accounts

final class StopRangeOfPaymentsViewControllerFactory {
    private let serviceItem: AccountsService
    private let buttonPresenterFactory: ButtonPresenterFactory
    
    init(serviceItem: AccountsService, buttonPresenterFactory: ButtonPresenterFactory) {
        self.serviceItem = serviceItem
        self.buttonPresenterFactory = buttonPresenterFactory
    }
    
    func create(stoppedRange: StoppedRange,
                account: Account,
                delegate: StopRangeOfPaymentsViewControllerDelegate) -> StopRangeOfPaymentsViewController {
        return StopRangeOfPaymentsViewController(
            stoppedRange: stoppedRange,
            account: account,
            serviceItem: serviceItem,
            delegate: delegate,
            buttonPresenterFactory: buttonPresenterFactory
        )
    }
}
