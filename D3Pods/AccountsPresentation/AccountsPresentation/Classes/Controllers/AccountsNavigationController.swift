//
//  AccountsNavigationController.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 5/11/18.
//

import UIKit
import Dip
import D3Accounts
import Transactions
import ComponentKit
import Session

final class AccountsNavigationController: UINavigationControllerComponent {
    init(accountsViewControllerFactory: AccountsVCFactory) {
        super.init(rootViewController: accountsViewControllerFactory.create())
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
