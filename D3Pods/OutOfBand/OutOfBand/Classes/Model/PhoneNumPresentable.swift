//
//  PhoneNumPresentable.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 1/12/21.
//

import Foundation
import UITableViewPresentation
import ComponentKit

protocol MobileCheckboxButtonDelegate: class {
    func mobileCheckboxTouched(checkbox: UICheckboxComponent, selectedCell: PhoneNumCell?)
}

final class PhoneNumPresentable: UITableViewPresentable {
    private let phoneNum: String
    private var selectedCell: PhoneNumCell? {
        didSet {
            self.selectedCell?.mobileCheckbox.accessibilityValue = self.isCheckBoxSelected ? "checked" : "unchecked"
        }
    }

    private var isCheckBoxSelected: Bool = false {
        willSet {
            self.selectedCell?.mobileCheckbox.accessibilityValue = newValue ? "checked" : "unchecked"
        }
    }

    private weak var delegate: MobileCheckboxButtonDelegate?
    
    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }
    
    init(phoneNum: String, delegate: MobileCheckboxButtonDelegate) {
        self.phoneNum = phoneNum
        self.delegate = delegate
    }
    
    func configure(cell: PhoneNumCell, at indexPath: IndexPath) {
        cell.mobileNumLabel.text = phoneNum
        cell.mobileCheckbox.boxType = .square
        cell.mobileCheckbox.removeTarget(nil, action: nil, for: .allEvents)
        cell.mobileCheckbox.addTarget(self, action: #selector(mobileCheckboxTouched(_ :)), for: .valueChanged)
        cell.mobileCheckbox.setCheckState(self.isCheckBoxSelected ? .checked : .unchecked, animated: true)
        self.selectedCell = cell
    }
    
    @objc func mobileCheckboxTouched(_ sender: UICheckboxComponent) {
        self.isCheckBoxSelected.toggle()
        self.selectedCell?.mobileCheckbox.setCheckState(self.isCheckBoxSelected ? .checked : .unchecked, animated: true)
        delegate?.mobileCheckboxTouched(checkbox: sender, selectedCell: self.selectedCell)
        updateAccessibilityValue()
    }
    
    private func updateAccessibilityValue() {
        self.selectedCell?.mobileCheckbox.accessibilityValue = self.isCheckBoxSelected ? "checked" : "unchecked"
    }
}

extension PhoneNumPresentable: Equatable {
    static func == (lhs: PhoneNumPresentable, rhs: PhoneNumPresentable) -> Bool {
        return lhs.phoneNum == rhs.phoneNum
    }
}

extension PhoneNumPresentable: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: OutOfBandBundle.bundle)
    }
}
