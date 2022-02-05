//
//  AccountDetailsHeader.swift
//  Accounts
//
//  Created by Branden Smith on 3/15/18.
//

import Foundation
import ComponentKit

class AccountDetailsHeader: UIView {
    @IBOutlet weak var accountNameLabel: UILabelComponent!
    @IBOutlet weak var balanceLabel: UILabelComponent!
    @IBOutlet weak var accountNumberLabel: UILabelComponent!
    @IBOutlet weak var availableBalanceLabel: UILabelComponent!
    @IBOutlet weak var statusLabel: UILabelComponent!
    @IBOutlet weak var lastUpdatedLabel: UILabelComponent!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var expandAndCollapseButton: UIButtonComponent!

    var standardHeaderCollapsedHeight: CGFloat {
        return 230.0
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }

    func loadNib() {
        guard let view = AccountsPresentationBundle
            .bundle
            .loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? UIView else { return }

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.makeMatch(view: self)
    }

    //swiftlint:disable:next function_parameter_count
    func updateView(withName name: String,
                    balance: String,
                    accountNumber: String,
                    availableBalance: String? = nil,
                    status: String,
                    lastUpdated: String) {
        accountNameLabel.text = name
        balanceLabel.text = balance
        accountNumberLabel.text = accountNumber
        availableBalanceLabel.text = availableBalance
        statusLabel.text = status
        lastUpdatedLabel.text = lastUpdated
    }

    func animateHeader(for viewController: UIViewController, with tableView: UITableView, settingHeaderToExpanded expanded: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            tableView.beginUpdates()

            // We need to layout the stack view here to make sure that its height is
            // updated for the header's height calculation.
            self.stackView.layoutIfNeeded()

            if expanded {
                self.stackView.alpha = 1.0
                let height = self.standardHeaderCollapsedHeight + self.stackView.bounds.height + 60
                self.frame = CGRect(
                    origin: .zero,
                    size: CGSize(width: tableView.bounds.width, height: height)
                )
                let image = UIImage(named: "VerticalCollapseIcon", in: AccountsPresentationBundle.bundle, compatibleWith: nil)
                self.expandAndCollapseButton.setImage(image, for: .normal)
            } else {
                self.stackView.alpha = 0.0
                self.frame = CGRect(
                    origin: .zero,
                    size: CGSize(width: tableView.bounds.width, height: self.standardHeaderCollapsedHeight)
                )
                let image = UIImage(named: "VerticalExpandIcon", in: AccountsPresentationBundle.bundle, compatibleWith: nil)
                self.expandAndCollapseButton.setImage(image, for: .normal)
            }

            viewController.view.layoutIfNeeded()
            tableView.endUpdates()
        })
    }
}
