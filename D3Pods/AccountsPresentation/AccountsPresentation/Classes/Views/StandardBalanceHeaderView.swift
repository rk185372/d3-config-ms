//
//  StandardBalanceHeaderView.swift
//  TransactionsPresentation
//
//  Created by Branden Smith on 3/8/18.
//

import Foundation
import UIKit
import ComponentKit

final class StandardBalanceHeaderView: UIView, BalanceHeaderView {
    @IBOutlet weak var balanceHeaderViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var accountNameLabel: UILabelComponent!

    @IBOutlet weak var manageButton: UIButtonComponent!
    @IBOutlet weak var manageButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var manageButtonTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var availableBalanceView: UIView!
    @IBOutlet weak var availableBalanceLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var availableBalanceViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var accountNumberLabel: UILabelComponent!
    @IBOutlet weak var statusLabel: UILabelComponent!

    @IBOutlet weak var balanceLabel: UILabelComponent!

    var currentHeight: CGFloat {
        return balanceHeaderViewHeightConstraint.constant
    }

    // This is not hard-coded to a size so that, when the
    // text grows and shrinks, the final alignment of the
    // acountNameLabel and the balanceLabel will be so that
    // their centers look aligned.
    private var maxHeaderHeight: CGFloat {
        // 17.0 is the original font size of the account name label
        // before text resizing. 98.0 is the original maximum height
        // of the view before changes from the default font size
        // are considered.
        return 98.0 + (accountNameLabel.font.pointSize - 17.0)
    }

    // This is not hard-coded to a size so that, when the
    // text grows and shrinks, the final alignment of the
    // acountNameLabel and the balanceLabel will be so that
    // their centers look aligned.
    private var minHeaderHeight: CGFloat {
        // 17.0 is the original font size of the account name label
        // before text resizing. 53.0 is the original minimum height
        // of the view before changes from the default font size
        // are considered.
        return 53.0 + (accountNameLabel.font.pointSize - 17.0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }

    private func loadNib() {
        guard let view = AccountsPresentationBundle.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?
            .first as? UIView else { return }

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.makeMatch(view: self)
    }

    func updateView(withName name: String, balance: String, accountNumber: String, status: String) {
        accountNameLabel.text = name
        balanceLabel.text = balance
        accountNumberLabel.text = accountNumber
        statusLabel.text = "Status: \(status)"
    }

    func updateHeight(withTableView tableView: UITableView,
                      given scrollViewDiff: CGFloat,
                      previousScrollViewOffset: CGFloat,
                      isScrollingUp: Bool,
                      isScrollingDown: Bool) {
        var newHeight = balanceHeaderViewHeightConstraint.constant

        if isScrollingDown {
            newHeight = max(minHeaderHeight, balanceHeaderViewHeightConstraint.constant - abs(scrollViewDiff))
        } else if isScrollingUp {
            newHeight = min(maxHeaderHeight, balanceHeaderViewHeightConstraint.constant + abs(scrollViewDiff))
        }

        if newHeight != balanceHeaderViewHeightConstraint.constant {
            balanceHeaderViewHeightConstraint.constant = newHeight
            tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: previousScrollViewOffset)
            animateHeader()
        }
    }

    private func animateHeader() {
        let range = maxHeaderHeight - minHeaderHeight
        let closedAmount = maxHeaderHeight - balanceHeaderViewHeightConstraint.constant
        let percentage = max(1 - (1.25 * (closedAmount / range)), 0)

        // 16.0 is the value of the top constraint's constant so,
        // as the view collapses, we want the constraint to be the beginning size minus
        // the amount that it is closed.
        manageButtonTopConstraint.constant = 16.0 - closedAmount
        manageButton.alpha = percentage

        availableBalanceViewTopConstraint.constant = 61.0 - closedAmount
        availableBalanceView.alpha = percentage
    }
}
