//
//  ChallengeRadioButtonView.swift
//  Authentication
//
//  Created by Chris Carranza on 7/10/18.
//

import UIKit
import ComponentKit
import RxSwift

final class ChallengeRadioButtonView: UIView {
    
    let bag = DisposeBag()
    
    @IBOutlet weak var radioButtonComponent: UIRadioButtonComponent!
    @IBOutlet weak var titleLabel: UILabelComponent!
    @IBOutlet weak var subtitleLabel: UILabelComponent!
    @IBOutlet weak var inputHolderView: UIView!
    @IBOutlet weak var inputField: UITextFieldComponent!
    @IBOutlet weak var inputFieldTooltipLabel: UILabelComponent!

    @IBOutlet weak var errorLabel: UILabelComponent!
    @IBOutlet weak var errorLabelHolder: UIView!
    @IBOutlet weak var radioButtonItemHolderView: UIView!
}
