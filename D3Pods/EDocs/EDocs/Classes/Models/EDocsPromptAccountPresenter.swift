//
//  EDocsPromptAccountPresenter.swift
//  EDocs
//
//  Created by Chris Carranza on 4/13/18.
//

import Foundation
import Localization
import RxSwift
import RxRelay
import UITableViewPresentation

final class EDocsPromptAccountPresenter: UITableViewPresentable {
    let account: EDocsPromptAccount
    fileprivate var _isSelected = BehaviorRelay(value: false)
    private let l10nProvider: L10nProvider!
    
    var isSelected: Bool {
        get { return _isSelected.value }
        set { _isSelected.accept(newValue) }
    }
    
    init(account: EDocsPromptAccount, l10nProvider: L10nProvider) {
        self.account = account
        self.l10nProvider = l10nProvider
    }
    
    func configure(cell: EDocsPromptAccountCell, at indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.checkbox.accessibilityElementsHidden = true
        cell.checkbox.setCheckState(isSelected ? .checked : .unchecked, animated: false)
        cell.accountNameLabel.text = account.accountName
        cell.accountNumberLabel.text = "(\(account.accountNumber.masked()))"
        
        cell.checkbox
            .rx
            .controlEvent(.valueChanged)
            .asObservable()
            .subscribe(onNext: { [unowned self] in
                self.isSelected.toggle()
                cell.checkbox.setCheckState(self.isSelected ? .checked : .unchecked, animated: true)
            })
            .disposed(by: cell.disposeBag)
        
        _isSelected
            .subscribe(onNext: { [unowned self, unowned cell] selected in
                cell.checkbox.setCheckState(selected ? .checked : .unchecked, animated: true)
                cell.accessibilityLabel = self.account.accountName
                cell.accessibilityValue = self.isSelected
                    ? self.l10nProvider.localize("paperless.checkbox.checked")
                    : self.l10nProvider.localize("paperless.checkbox.unchecked")
                let parameterMap = ["accountName": self.account.accountName]
                cell.accountNameLabel.accessibilityValue = self.isSelected
                    ? self.l10nProvider.localize("paperless.accountNamecheckbox.checked", parameterMap: parameterMap)
                    : self.l10nProvider.localize("paperless.accountNamecheckbox.unchecked", parameterMap: parameterMap)
            })
            .disposed(by: cell.disposeBag)
    }
    
    static func == (lhs: EDocsPromptAccountPresenter, rhs: EDocsPromptAccountPresenter) -> Bool {
        return lhs.account == rhs.account && lhs.isSelected == rhs.isSelected
    }
}

extension EDocsPromptAccountPresenter: ReactiveCompatible {}

extension Reactive where Base: EDocsPromptAccountPresenter {
    var isSelected: Observable<Bool> {
        return base._isSelected.asObservable()
    }
}

extension EDocsPromptAccountPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: EDocsBundle.bundle)
    }
}
