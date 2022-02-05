//
//  FooterButtonsPresentable.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 12/31/20.
//

import Foundation
import UITableViewPresentation
import ComponentKit

protocol FooterButtonsDelegate: class {
    func cancelButtonTouched(_ sender: UIButtonComponent)
    func continueButtonTouched(_ sender: UIButtonComponent)
}

final class FooterButtonsPresentable: UITableViewPresentable {
    private let cancelBtnTitle: String
    private let continueBtnTitle: String
    private weak var delegate: FooterButtonsDelegate?
    
    var cellReuseIdentifier: String {
        return "FooterButtonsCell"
    }
    
    init(cancelText: String,continueText: String, delegate: FooterButtonsDelegate) {
        self.cancelBtnTitle = cancelText
        self.continueBtnTitle = continueText
        self.delegate = delegate
    }
    
    func configure(cell: FooterButtonsCell, at indexPath: IndexPath) {
        cell.cancelButton.setTitle(cancelBtnTitle, for: .normal)
        cell.continueButton.setTitle(continueBtnTitle, for: .normal)
        cell.cancelButton.addTarget(self, action: #selector(cancelButtonTouched(_:)), for: .touchUpInside)
        cell.continueButton.addTarget(self, action: #selector(continueButtonTouched(_:)), for: .touchUpInside)
    }
    
    @objc private func cancelButtonTouched(_ sender: UIButtonComponent) {
        delegate?.cancelButtonTouched(sender)
    }
    
    @objc private func continueButtonTouched(_ sender: UIButtonComponent) {
        delegate?.continueButtonTouched(sender)
    }
}

extension FooterButtonsPresentable: Equatable {
    static func == (_ lhs: FooterButtonsPresentable, _ rhs: FooterButtonsPresentable) -> Bool {
        return lhs.continueBtnTitle == rhs.continueBtnTitle
            && lhs.cancelBtnTitle == rhs.cancelBtnTitle
    }
}

extension FooterButtonsPresentable: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: OutOfBandBundle.bundle)
    }
}
