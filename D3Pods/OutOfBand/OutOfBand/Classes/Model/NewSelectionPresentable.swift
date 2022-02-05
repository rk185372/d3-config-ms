//
//  NewSelectionPresentable.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 1/2/21.
//

import Foundation
import UITableViewPresentation
import RxSwift
import RxCocoa
import Views
import ComponentKit

protocol NewSelectionPresentableDelegate: class {
    func keyboardClearButtonTouched(_ sender: UIBarButtonItem, currentCellText: String, isEmail: Bool)
    func checkIfEmailPhoneNumberExistsInUserProfile(currentCellText: String, isEmail: Bool) -> Bool
    func setErrorField(value: Bool, isEmail: Bool)
}

final class NewSelectionPresentable: NSObject, UITableViewPresentable {
    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }
    
    private let placeholder: String
    private let infoText: String
    private var textField: UITextField!
    private var invalidErrorText: String
    private var itemListedErrorText: String
    private var isEmailCell: Bool
    private weak var delegate: NewSelectionPresentableDelegate?
    private let bag = DisposeBag()
    private var inputValue = ""
    private var isCurrentStringValid: Bool = true {
        willSet {
            self.errorTextLabel.isHidden = newValue
        }
    }    
    private var errorTextLabel: UILabelComponent! {
        didSet {
            errorTextLabel.isHidden = self.isCurrentStringValid
        }
    }
    
    init(placeholder: String,
         infoText: String,
         invalidErrorText: String,
         itemListedErrorText: String,
         isEmailCell: Bool,
         delegate: NewSelectionPresentableDelegate) {
        self.placeholder = placeholder
        self.infoText = infoText
        self.delegate = delegate
        self.invalidErrorText = invalidErrorText
        self.itemListedErrorText = itemListedErrorText
        self.isEmailCell = isEmailCell
    }
    
    func configure(cell: NewSelectionCell, at indexPath: IndexPath) {
        errorTextLabel = cell.errorLabel
        errorTextLabel.text = self.invalidErrorText
        cell.textfield.placeholder = placeholder
        cell.textfield.clearButtonMode = .never
        cell.infoLabel.text = infoText
        cell.textfield.delegate = self
        cell.textfield.text = self.inputValue
    }
}

extension NewSelectionPresentable: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: OutOfBandBundle.bundle)
    }
}

extension NewSelectionPresentable: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          textField.resignFirstResponder()
          return true
      }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentText = textField.text,
            let textRange = Range(range, in: currentText) {
            let updatedText = currentText.replacingCharacters(in: textRange, with: string)
            self.errorTextLabel.text = self.invalidErrorText
            self.inputValue = updatedText
            updateEmailAddressAndPhoneNumsInViewController(currentText: updatedText)
        }
        return true
    }
    
    private func updateEmailAddressAndPhoneNumsInViewController(currentText: String) {
        var isValidInput = false
        if(self.isEmailCell) {
            isValidInput = currentText == "" || currentText.isValidEmail()
        } else {
            isValidInput = currentText == "" || currentText.isValidPhone()
        }
        self.isCurrentStringValid = isValidInput
        if(!isValidInput) {
            self.delegate?.setErrorField(value: true, isEmail: self.isEmailCell)
        } else {
            updateUserProfile(currentCellText: currentText)
        }
    }
    
    private func updateUserProfile(currentCellText: String) {
        let isInputExistsAlready = self.delegate?.checkIfEmailPhoneNumberExistsInUserProfile(
            currentCellText: currentCellText,
            isEmail: self.isEmailCell) ?? false
        
        // If the text is empty, means user deleted the value in the text field and it is fresh.
        if(currentCellText == "") {
            self.delegate?.setErrorField(value: false, isEmail: self.isEmailCell)
            return
        }

        if(isInputExistsAlready) {
            self.isCurrentStringValid = true
        } else {
            self.errorTextLabel.text = self.itemListedErrorText
            self.isCurrentStringValid = false
        }
    }
}
