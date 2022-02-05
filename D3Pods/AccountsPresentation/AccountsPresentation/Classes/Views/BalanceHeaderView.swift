//
//  BalanceHeaderView.swift
//  TransactionsPresentation
//
//  Created by Branden Smith on 3/8/18.
//

import D3Accounts
import Foundation
import UIKit
import ComponentKit

protocol BalanceHeaderView {
    var currentHeight: CGFloat { get }
    var manageButton: UIButtonComponent! { get }

    func updateView(withName name: String, balance: String, accountNumber: String, status: String)
    func updateHeight(withTableView tableView: UITableView,
                      given scrollViewDiff: CGFloat,
                      previousScrollViewOffset: CGFloat,
                      isScrollingUp: Bool,
                      isScrollingDown: Bool)
}
