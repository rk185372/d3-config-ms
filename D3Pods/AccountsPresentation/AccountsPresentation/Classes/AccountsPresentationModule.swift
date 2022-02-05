//
//  AccountsPresentationModule.swift
//  Pods
//
//  Created by Branden Smith on 1/10/19.
//

import D3Accounts
import Dip
import DependencyContainerExtension
import Foundation
import Messages
import Transactions
import Web

public final class AccountsPresentationModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register { AccountsServiceItem(client: $0) as AccountsService }
        container.register {
            AccountsVCFactory(
                l10nProvider: try container.resolve(),
                componentStyleProvider: try container.resolve(),
                accountsService: try container.resolve(),
                transactionsViewControllerFactory: try container.resolve(),
                buttonPresenterFactory: try container.resolve(),
                userSession: try container.resolve(),
                companyAttributes: try container.resolve(),
                externalWebViewControllerFactory: try container.resolve(),
                addOfflineAccountViewControllerFactory: try container.resolve(),
                profileIconCoordinatorFactory: try container.resolve()
            )
        }
        container.register {
            AccountDetailsViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1,
                serviceItem: $2,
                cardControlsViewControllerFactory: $3,
                stopPaymentViewControllerFactory: $4
            )
        }
        container.register { TransactionsServiceItem(client: $0) as TransactionsService }
        container.register {
            TransactionsViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1,
                transactionsService: $2,
                accountDetailsViewControllerFactory: $3
            )
        }
        container.register { ButtonPresenterFactory(styleProvider: $0) }
        container.register {
            StopPaymentViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1,
                serviceItem: $2,
                stopSinglePaymentViewControllerFactory: $3,
                stopRangeOfPaymentsViewControllerFactory: $4
            )
        }
        container.register {
            CardControlsViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1,
                buttonPresenterFactory: $2,
                serviceItem: $3
            )
        }
        container.register { StopSinglePaymentViewControllerFactory(serviceItem: $0, buttonPresenterFactory: $1) }
        container.register { StopRangeOfPaymentsViewControllerFactory(serviceItem: $0, buttonPresenterFactory: $1) }
        container.register { AddOfflineAccountViewControllerFactory(serviceItem: $0, l10nProvider: $1, componentStyleProvider: $2) }
    }
}
