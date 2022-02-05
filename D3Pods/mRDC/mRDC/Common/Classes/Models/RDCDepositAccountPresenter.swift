//
//  RDCDepositAccountPresenter.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/14/18.
//

import Foundation
import UITableViewPresentation
import D3Accounts
import Localization
import Utilities
import RxSwift
import RxRelay

struct SelectedCell: Codable {
    let isSelected: Bool
}

protocol RDCDepositAccountPresenterDelegate: class {
    func didSelectPresenter(presenter: RDCDepositAccountPresenter)
}

final class RDCDepositAccountPresenter: UITableViewPresentable {
    let depositAccount: DepositAccount
    private let l10nProvider: L10nProvider

    fileprivate var _isSelected = BehaviorRelay(value: false)
    
    weak var delegate: RDCDepositAccountPresenterDelegate?
    
    var isSelected: Bool {
        get { return _isSelected.value }
        set { _isSelected.accept(newValue) }
    }

    init(depositAccount: DepositAccount, l10nProvider: L10nProvider) {
        self.depositAccount = depositAccount
        self.l10nProvider = l10nProvider
    }
    
    func configure(cell: RDCAccountCell, at indexPath: IndexPath) {
        let balance = NumberFormatter.currencyFormatter(currencyCode: depositAccount.currencyCode)
            .string(from: depositAccount.balance)!

        cell.accountNameLabel.text = (depositAccount.nickname != nil && !depositAccount.nickname!.isEmpty)
            ? depositAccount.nickname
            : depositAccount.name
        
        cell.accountBalanceLabel.text = balance
        cell.accountNumberLabel.text = depositAccount.number
        cell.accountNumberLabel.isHidden = depositAccount.number == nil

        let substitutionParams = [
            "accountName": depositAccount.displayableName,
            "balance": balance
        ]
        cell.accessibilityLabel = l10nProvider.localize(
            "rdc.depositAccountCell.accessibilityLabel",
            parameterMap: substitutionParams
        ) + "checkbox"

        cell.checkbox.accessibilityIdentifier = "checkbox-\(depositAccount.name)"
        
        cell.checkbox
            .rx
            .controlEvent(.valueChanged)
            .asObservable()
            .subscribe(onNext: { [unowned self] in
                self.delegate?.didSelectPresenter(presenter: self)
            })
            .disposed(by: cell.disposeBag)
        
        _isSelected
            .subscribe(onNext: { [unowned cell] selected in
                cell.checkbox.setCheckState(selected ? .checked : .unchecked, animated: true)
                cell.accessibilityValue = selected ? "checked" : "unchecked"
            })
            .disposed(by: cell.disposeBag)
    }
}

extension RDCDepositAccountPresenter: ReactiveCompatible {}

extension Reactive where Base: RDCDepositAccountPresenter {
    var isSelected: Observable<Bool> {
        return base._isSelected.asObservable()
    }
}

extension RDCDepositAccountPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: RDCBundle.bundle)
    }
}

extension RDCDepositAccountPresenter: UITableViewEditableRow {
    var isEditable: Bool { return false }
    
    func editActions() -> [UITableViewRowAction]? {
        return nil
    }
}

extension RDCDepositAccountPresenter: Equatable {
    static func ==(lhs: RDCDepositAccountPresenter, rhs: RDCDepositAccountPresenter) -> Bool {
        guard lhs.depositAccount == rhs.depositAccount &&
            lhs.isSelected == rhs.isSelected else { return false }
        
        return true
    }
}
