//
//  RDCDisclosurePresenter.swift
//  Pods
//
//  Created by Chris Pflepsen on 8/14/18.
//

import Foundation
import UITableViewPresentation
import D3Accounts
import Utilities
import Localization

final class RDCAccountLimitInformationCellPresenter: UITableViewPresentable {
    let account: DepositAccount
    let l10nProvider: L10nProvider

    init(l10nProvider: L10nProvider,
         depositAccount: DepositAccount) {
        self.account = depositAccount
        self.l10nProvider = l10nProvider
    }

    func configure(cell: RDCAccountLimitInformationCell, at indexPath: IndexPath) {
        guard let duration = account.duration() else {
            return
        }
        
        var informationString = ""
        let period = getPeriodString(duration: duration)
        var tier2Period = ""
        
        let tier2Duration = account.tier2Duration()
        
        if let tier2Duration = tier2Duration {
            tier2Period = getPeriodString(duration: tier2Duration)
        }
        
        //Deposit Remaining And Total Allowed Amounts
        if let amount = account.amount(), let remainingAmount = account.remainingAmount(),
           let tier2Amount = account.tier2Amount(), let tier2RemainingAmount = account.tier2RemainingAmount() {
            informationString.append(
                l10nProvider.localize("deposit.disclosure.limit.tier2_amounts", parameterMap: [
                    "depositAmount": remainingAmount,
                    "amount": amount,
                    "period": period,
                    "tier2DepositAmount": tier2RemainingAmount,
                    "tier2Amount": tier2Amount,
                    "tier2period": tier2Period
                    ]
                )
            )
        } else if let amount = account.amount(), let remainingAmount = account.remainingAmount() {
            
            informationString.append(l10nProvider.localize("deposit.disclosure.limit.amounts", parameterMap: [
                "depositAmount": remainingAmount,
                "amount": amount,
                "period": period
                ])
            )
        } else if let tier2Amount = account.tier2Amount(), let tier2RemainingAmount = account.tier2RemainingAmount() {
            informationString.append(l10nProvider.localize("deposit.disclosure.limit.amounts", parameterMap: [
                "depositAmount": tier2RemainingAmount,
                "amount": tier2Amount,
                "period": tier2Period
                ])
            )
        }
        
        //Total remaining checks and total allowed checks limit
        if let count = account.depositCount(), let tier2Count = account.tier2DepositCount(),
           let limit = account.limit(), let tier2Limit = account.tier2Limit() {
            var checkLimitString = ""
            let shouldShow = Int(limit) != 0
            let shouldShowForTier2 = Int(tier2Limit) != 0
            
            if(shouldShow && shouldShowForTier2) {
                checkLimitString += l10nProvider.localize("deposit.disclosure.limit.checks_tier2", parameterMap: [
                    "depositCount": count,
                    "limit": limit,
                    "period": period,
                    "tier2Count": tier2Count,
                    "tier2limit": tier2Limit,
                    "tier2period": tier2Period
                ])
            } else if (shouldShow) {
                checkLimitString += l10nProvider.localize("deposit.disclosure.limit.checks", parameterMap: [
                    "depositCount": count,
                    "limit": limit,
                    "period": period
                ])
            } else if (shouldShowForTier2) {
                checkLimitString += l10nProvider.localize("deposit.disclosure.limit.checks", parameterMap: [
                    "depositCount": tier2Count,
                    "limit": tier2Limit,
                    "period": tier2Period
                ])
            }
            
            if !informationString.isEmpty { informationString.append("\n\n") }
                informationString.append(checkLimitString)
        }
    
        cell.accountLimitLabel.text = informationString
    }
}

extension RDCAccountLimitInformationCellPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: RDCBundle.bundle)
    }
}

extension RDCAccountLimitInformationCellPresenter: UITableViewEditableRow {
    var isEditable: Bool { return false }
    
    func editActions() -> [UITableViewRowAction]? {
        return nil
    }
}

extension RDCAccountLimitInformationCellPresenter: Equatable {
    static func ==(lhs: RDCAccountLimitInformationCellPresenter, rhs: RDCAccountLimitInformationCellPresenter) -> Bool {
        guard lhs.account == rhs.account else { return false }
        
        return true
    }
}

extension RDCAccountLimitInformationCellPresenter {
    
    func getPeriodString(duration: RDCDuration) -> String {
        switch duration {
        case .daily:
            return l10nProvider.localize("deposit.duration.daily")
        case .weekly:
            return l10nProvider.localize("deposit.duration.weekly")
        default:
            return l10nProvider.localize("deposit.duration.monthly")
        }
    }
}
