//
//  SelectAllPresenter.swift
//  EDocs
//
//  Created by Chris Carranza on 11/1/18.
//

import ComponentKit
import Foundation
import Localization
import RxRelay
import RxSwift
import UITableViewPresentation

final class SelectAllPresenter: UITableViewPresentable {
    fileprivate var _isSelected = BehaviorRelay(value: false)
    fileprivate var _checkboxTapped = BehaviorRelay(value: ())
    private let l10nProvider: L10nProvider!

    private let checkboxTitle: String
    
    var isSelected: Bool {
        get { return _isSelected.value }
        set { _isSelected.accept(newValue) }
    }
    
    init(checkboxTitle: String, l10nProvider: L10nProvider) {
        self.checkboxTitle = checkboxTitle
        self.l10nProvider = l10nProvider
    }
    
    func configure(cell: SelectAllCell, at indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.checkbox.accessibilityElementsHidden = true
        cell.checkbox.setCheckState(isSelected ? .checked : .unchecked, animated: false)
        cell.titleLabel.text = checkboxTitle

        let tapRecognizer = UITapGestureRecognizer()
        cell.titleLabel.addGestureRecognizer(tapRecognizer)

        let combinedTap = Observable
            .of(
                tapRecognizer.rx.event.asObservable().mapToVoid(),
                cell.checkbox.rx.controlEvent(.valueChanged).asObservable()
            )
            .merge()
        
        combinedTap
            .do(onNext: { _ in
                self.isSelected.toggle()
                cell.checkbox.accessibilityValue = self.checkboxAccessibilityString()
                cell.checkbox.setCheckState(self.isSelected ? .checked : .unchecked, animated: true)
                
                let parameterMap = ["checkboxTitle": self.checkboxTitle]
                cell.titleLabel.accessibilityLabel = self.isSelected
                    ? self.l10nProvider.localize("paperless.checkboxTitle.checked", parameterMap: parameterMap)
                    : self.l10nProvider.localize("paperless.checkboxTitle.unchecked", parameterMap: parameterMap)
            })
            .bind(to: _checkboxTapped)
            .disposed(by: cell.disposeBag)
        
        _isSelected
            .subscribe(onNext: { [unowned self, unowned cell] selected in
                cell.checkbox.setCheckState(selected ? .checked : .unchecked, animated: true)
                cell.accessibilityLabel = self.checkboxTitle
                cell.accessibilityValue = self.checkboxAccessibilityString()
            })
            .disposed(by: cell.disposeBag)
    }
    
    private func checkboxAccessibilityString() -> String {
        return self.isSelected
            ? self.l10nProvider.localize("paperless.checkbox.checked")
            : self.l10nProvider.localize("paperless.checkbox.unchecked")
    }
    
    static func == (lhs: SelectAllPresenter, rhs: SelectAllPresenter) -> Bool {
        return lhs.isSelected == rhs.isSelected
    }
}

extension SelectAllPresenter: ReactiveCompatible {}

extension Reactive where Base: SelectAllPresenter {
    var isSelected: Observable<Bool> {
        return base._isSelected.asObservable()
    }
    
    var checkboxTapped: Observable<Bool> {
        return base._checkboxTapped.map { self.base.isSelected }.asObservable()
    }
}

extension SelectAllPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: EDocsBundle.bundle)
    }
}
