//
//  SecurityQuestionView.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/5/18.
//

import ComponentKit
import Foundation
import UIKit

final class SecurityQuestionView: UIView {
    @IBOutlet weak var questionStackView: UIStackView!
    @IBOutlet weak var questionLabel: UILabelComponent!
    @IBOutlet weak var disclosureIndicatorView: UIImageView!
    @IBOutlet weak var textField: UITextFieldComponent!
    @IBOutlet weak var errorLabel: UILabelComponent!
}
