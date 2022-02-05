//
//  RDCCheckImagePresenter.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/14/18.
//

import Foundation
import UITableViewPresentation
import D3Accounts
import Utilities
import UIKit
import ComponentKit
import Localization
import RxSwift
import RxRelay
import Views

final class RDCCheckImagePresenter: NSObject {
    
    enum PressedButtonType {
        case captureCheck, captureCheckFront, captureCheckBack
    }
    
    private var l10nProvider: L10nProvider
    private let componentStyleProvider: ComponentStyleProvider
    private var captureGestureRecognizer: UITapGestureRecognizer!
    private var captureFrontGestureRecognizer: UITapGestureRecognizer!
    private var captureBackGestureRecognizer: UITapGestureRecognizer!
    
    var images: RDCCaptureImages?
    private var depositAmount: Decimal = 0
    
    var clickListener: ((PressedButtonType) -> Void)?
    var textListener: ((Decimal) -> Void)?
    var doneListener: (() -> Void)?
    
    let formatter: NumberFormatter = {
        let f = NumberFormatter.currencyFormatter()
        f.roundingMode = .down
        return f
    }()
    
    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         depositAmount: Decimal?,
         images: RDCCaptureImages?,
         clickListener: ((PressedButtonType) -> Void)? = nil,
         textListener: ((Decimal) -> Void)? = nil,
         doneListener: (() -> Void)? = nil) {
        self.l10nProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.clickListener = clickListener
        self.textListener = textListener
        self.doneListener = doneListener
        self.images = images
        self.depositAmount = depositAmount ?? 0
        super.init()
        
        captureGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(captureCheckButtonTouched))
        captureFrontGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(captureCheckFrontButtonTouched))
        captureBackGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(captureCheckBackButtonTouched))
    }
    
    @objc private func captureCheckButtonTouched() {
        clickListener?(.captureCheck)
    }
    
    @objc private func captureCheckFrontButtonTouched() {
        clickListener?(.captureCheckFront)
    }
    
    @objc private func captureCheckBackButtonTouched() {
        clickListener?(.captureCheckBack)
    }
    
    @objc private func textChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        guard let value = NumberFormatter.currencyFormatter().number(from: text)?.decimalValue else { return }
        textListener?(value)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let lhs = object as? RDCCheckImagePresenter else { return false }
        
        guard lhs.images == images
            && lhs.depositAmount == depositAmount else { return false }
        
        return true
    }
}

extension RDCCheckImagePresenter: UITableViewPresentable {
    
    func configure(cell: RDCCheckImageCell, at indexPath: IndexPath) {
        let title = l10nProvider.localize("dashboard.widget.deposit.btn.capture")
        cell.stackedMenuView.titleLabel.text = title
        cell.stackedMenuView.accessibilityLabel = title
        cell.stackedMenuView.accessibilityTraits = [.button]
        cell.stackedMenuView.setTapGestureRecognizer(captureGestureRecognizer)
        cell.stackedMenuView.imageView.image = UIImage(named: "RDC_Camera", in: RDCBundle.bundle, compatibleWith: nil)

        let stackedMenuStyle: StackedMenuViewStyle = componentStyleProvider["stackedMenuOnDefaultAlternate"]
        stackedMenuStyle.style(component: cell.stackedMenuView)
        
        cell.amountTextField.delegate = self
        let amountFormatted = NumberFormatter.currencyFormatter().string(from: (depositAmount as NSDecimalNumber))
        cell.amountTextField.text = amountFormatted
        cell.amountTextField.accessibilityIdentifier = "deposit-amount-textField"
        cell.amountTextField.accessibilityLabel = "Enter amount - Required"
        cell.amountTextField.removeTarget(nil, action: nil, for: .allEvents)
        cell.amountTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)

        let numberPad = ViewsBundle
            .bundle
            .loadNibNamed("CustomNumberPad", owner: nil, options: nil)?
            .first as? CustomNumberPad

        numberPad?.target = cell.amountTextField

        cell.amountTextField.inputView = numberPad

        if let images = images {
            cell.imageStackView.isHidden = false
            cell.instructionLabel.isHidden = true
            guard let frontData = Data(base64Encoded: images.encodedFrontImage),
                let backData = Data(base64Encoded: images.encodedBackImage) else {
                    return
            }
            
            cell.frontImageView.image = UIImage(data: frontData)
            cell.frontImageView.accessibilityLabel = l10nProvider.localize("rdc.frontCheckImage.accessibilityLabel")
            cell.frontImageView.setTapGestureRecognizer(captureFrontGestureRecognizer)
            cell.frontImageView.isUserInteractionEnabled = true
            
            cell.backImageView.image = UIImage(data: backData)
            cell.backImageView.accessibilityLabel = l10nProvider.localize("rdc.backCheckImage.accessibilityLabel")
            cell.backImageView.setTapGestureRecognizer(captureBackGestureRecognizer)
            cell.backImageView.isUserInteractionEnabled = true
        } else {
            cell.frontImageView.image = nil
            cell.backImageView.image = nil
            
            cell.imageStackView.isHidden = true
            
        }
    }
}

extension RDCCheckImagePresenter: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.text == "" else {
            return
        }
        textField.text = NumberFormatter.currencyFormatter().string(from: 0)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Ensure we either have the empty string (removing a digit) or we got a digit and
        // that we already have text in the text field. (This should always be the case)
        guard string.isEmpty || Decimal(string: string) != nil else { return false }
        guard let currentText = textField.text else { return false }

        // Remove all non digits from the current text (i.e. currency symbol, commas, and decimal)
        var cleanedString = currentText.removing(charactersInSet: CharacterSet.decimalDigits.inverted)

        if string.isEmpty {
            cleanedString = String(cleanedString.dropLast())
        } else {
            cleanedString += string
        }

        guard let decimalFromCleanedString = Decimal(string: cleanedString) else { return false }
        let newAmount = decimalFromCleanedString / Decimal(100)
        guard newAmount < 1_000_000_000 else { return false }

        textField.text = formatter.string(from: NSDecimalNumber(decimal: newAmount))
        self.textChanged(textField)

        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        doneListener?()
        return true
    }
}

extension RDCCheckImagePresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: RDCBundle.bundle)
    }
}

extension RDCCheckImagePresenter: UITableViewEditableRow {
    var isEditable: Bool { return false }
    
    func editActions() -> [UITableViewRowAction]? {
        return nil
    }
}

private extension UIView {
    func setTapGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        gestureRecognizers?.forEach { self.removeGestureRecognizer($0) }
        addGestureRecognizer(recognizer)
    }
}
