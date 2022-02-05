//
//  RDCDepositTransactionPresenter.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/2/18.
//

import Foundation
import UITableViewPresentation
import D3Accounts
import Utilities

final class RDCDepositTransactionPresenter: UITableViewPresentable {
    let transaction: DepositTransaction
    
    init(depositTransaction: DepositTransaction) {
        self.transaction = depositTransaction
    }
    
    func configure(cell: RDCDepositTransactionCell, at indexPath: IndexPath) {
        cell.statusLabel.text = transaction.status
        cell.amountLabel.text = NumberFormatter.currencyFormatter().string(from: transaction.currentAmount)
        cell.topDividerView.isHidden = (indexPath.row == 0)
        cell.backgroundColor = .clear
    }
}

extension RDCDepositTransactionPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: RDCBundle.bundle)
    }
}

extension RDCDepositTransactionPresenter: UITableViewEditableRow {
    var isEditable: Bool { return false }
    
    func editActions() -> [UITableViewRowAction]? {
        return nil
    }
}

extension RDCDepositTransactionPresenter: Equatable {
    static func ==(lhs: RDCDepositTransactionPresenter, rhs: RDCDepositTransactionPresenter) -> Bool {
        guard lhs.transaction == rhs.transaction else { return false }
        
        return true
    }
}
