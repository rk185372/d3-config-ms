//
//  TwoButtonCell.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/22/18.
//

import Foundation
import UIKit
import ComponentKit

final class TwoButtonCell: UITableViewCell {
    @IBOutlet weak var leftButton: UIButtonComponent!
    @IBOutlet weak var rightButton: UIButtonComponent!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var leftButtonView: UIView!
    @IBOutlet weak var rightButtonView: UIView!
    @IBOutlet weak var leftButtonViewTrailingConstraint: NSLayoutConstraint!
}
