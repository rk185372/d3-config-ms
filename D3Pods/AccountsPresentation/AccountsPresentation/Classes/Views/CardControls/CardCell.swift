//
//  CardCell.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/5/18.
//

import Foundation
import UIKit
import ComponentKit

final class CardCell: UITableViewCell {
    @IBOutlet weak var maskedAccountNumberLabel: UILabelComponent!
    @IBOutlet weak var cardHolderLabel: UILabelComponent!
    @IBOutlet weak var activateCardSwitch: UISwitchComponent!
    @IBOutlet weak var activeLabel: UILabelComponent!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}
