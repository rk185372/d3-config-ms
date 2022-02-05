//
//  EmailAddressPresentable.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 1/13/21.
//

import Foundation
import UITableViewPresentation
import ComponentKit

protocol EmailCheckboxButtonDelegate: class {
    func emailCheckboxTouched(checkbox: UICheckboxComponent, selectedCell: EmailAddressCell?)
}

final class EmailAddressPresentable: UITableViewPresentable {
    private let email: String
    private var selectedCell: EmailAddressCell? {
        didSet {
            self.selectedCell?.emailCheckbox.accessibilityValue = self.isCheckBoxSelected ? "checked" : "unchecked"
        }
    }
    private var isCheckBoxSelected: Bool = false {
        willSet {
            self.selectedCell?.emailCheckbox.accessibilityValue = newValue ? "checked" : "unchecked"
        }
    }

    private weak var delegate: EmailCheckboxButtonDelegate?
    
    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }
    
    init(email: String, delegate: EmailCheckboxButtonDelegate) {
        self.email = email
        self.delegate = delegate
    }
    
    func configure(cell: EmailAddressCell, at indexPath: IndexPath) {
        cell.emailAdressLabel.text = email
        cell.emailCheckbox.boxType = .square
        cell.emailCheckbox.removeTarget(nil, action: nil, for: .allEvents)
        cell.emailCheckbox.addTarget(self, action: #selector(emailcheckboxTouched(_ :)), for: .valueChanged)
        cell.emailCheckbox.setCheckState(self.isCheckBoxSelected ? .checked : .unchecked, animated: true)
        self.selectedCell = cell
    }
    
    @objc func emailcheckboxTouched(_ sender: UICheckboxComponent) {
        self.isCheckBoxSelected.toggle()
        self.selectedCell?.emailCheckbox.setCheckState(self.isCheckBoxSelected ? .checked : .unchecked, animated: true)
        delegate?.emailCheckboxTouched(checkbox: sender, selectedCell: self.selectedCell)
        updateAccessibilityValue()
    }
    
    private func updateAccessibilityValue() {
        self.selectedCell?.emailCheckbox.accessibilityValue = self.isCheckBoxSelected ? "checked" : "unchecked"
    }
}

extension EmailAddressPresentable: Equatable {
    static func == (lhs: EmailAddressPresentable, rhs: EmailAddressPresentable) -> Bool {
        return lhs.email == rhs.email
    }
}

extension EmailAddressPresentable: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: OutOfBandBundle.bundle)
    }
}
