//
//  AccountRow.swift
//  Snapshot
//
//  Created by Andrew Watt on 8/17/18.
//

import AccountsPresentation
import Localization
import Snapshot
import UIKit
import UITableViewPresentation
import Utilities

class AccountRow: UITableViewPresentable {
    let account: Snapshot.Account

    private let l10nProvider: L10nProvider
    private var isAccountBadgeEnabled: Bool

    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }

    required init(account: Snapshot.Account,
                  l10nProvider: L10nProvider,
                  isAccountBadgeEnabled: Bool) {
        self.account = account
        self.l10nProvider = l10nProvider
        self.isAccountBadgeEnabled = isAccountBadgeEnabled
    }
    
    func configure(cell: AccountCell, at indexPath: IndexPath) {
        // If Account badge is enabled in Company attributes, Show the badge in circle else hide it.
        if isAccountBadgeEnabled {
            cell.accountCircle.label.text = account.name.abbreviated()
        } else {
            cell.accountCircle.widthAnchor.constraint(equalToConstant: 0).isActive = true
        }
        
        cell.nameLabel.text = account.name

        if let balance = account.balance {
            cell.balanceLabel.text = balance.formatted(currencyCode: account.currencyCode)

            let accountType = l10nProvider.localize(balance.type.l10nKey)
            var asOfDateString = ""
            if let date = balance.asOfDate {
                let dateString = DateFormatter.shortStyleExcludingTime.string(from: date)
                asOfDateString = l10nProvider.localize(
                    "launchPage.snapshot.detail.balance-date",
                    parameterMap: [
                        "date": dateString
                ])
            }
            let balanceDescription = l10nProvider.localize(
                "launchPage.snapshot.detail.balance-description",
                parameterMap: [
                    "accountType": accountType,
                    "balanceDate": asOfDateString
            ])

            cell.balanceTypeLabel.isHidden = accountType.isEmpty
            cell.balanceTypeLabel.text = balanceDescription
        } else {
            cell.balanceLabel.isHidden = true
            cell.balanceTypeLabel.isHidden = true
        }

        cell.accessoryType = .disclosureIndicator

        let maskedAccountNumber = account.number.masked()
        cell.accountNumberLabel.text = maskedAccountNumber

        let paramMap = [
            "number": Array(maskedAccountNumber.removing(charactersInSet: CharacterSet.decimalDigits.inverted))
                .map({ String($0) })
                .joined(separator: " ")
        ]

        cell.accountNumberLabel.accessibilityLabel = l10nProvider
            .localize("launchPage.snapshot.accountNumber.accessibilityLabel", parameterMap: paramMap)
    }
}

extension AccountRow: Equatable {
    static func ==(_ lhs: AccountRow, _ rhs: AccountRow) -> Bool {
        return lhs.account == rhs.account && lhs.cellReuseIdentifier == rhs.cellReuseIdentifier
    }
}

extension AccountRow: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}
