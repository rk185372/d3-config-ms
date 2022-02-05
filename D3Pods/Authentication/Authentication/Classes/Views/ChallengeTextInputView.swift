//
//  ChallengeTextInputView.swift
//  Authentication
//
//  Created by Chris Carranza on 6/15/18.
//

import UIKit
import ComponentKit

final class ChallengeTextInputView: UIView {
    @IBOutlet weak var titleLabel: UILabelComponent!
    @IBOutlet weak var textField: AnimatableTitleTextField!
    @IBOutlet weak var errorLabel: UILabelComponent!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoButton: UIButton!
}
