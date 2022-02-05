//
//  EmailVerificationView.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/6/21.
//

import ComponentKit
import Foundation
import UIKit

final class EmailInputView: UIView {
    @IBOutlet weak var textField: AnimatableTitleTextField!
    @IBOutlet weak var errorLabel: UILabelComponent!
    @IBOutlet weak var underlineView: UIView!
}
