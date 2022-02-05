//
//  StopPaymentHistoryCell.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/19/18.
//

import Foundation
import UIKit
import ComponentKit

final class StopPaymentHistoryCell: UITableViewCell {
    @IBOutlet weak var expirationDateLabel: UILabelComponent!
    @IBOutlet weak var amountLabel: UILabelComponent!
    @IBOutlet weak var reasonLabel: UILabelComponent!
    @IBOutlet weak var checkNumberLabel: UILabelComponent!
    @IBOutlet weak var payeeLabel: UILabelComponent!
    @IBOutlet weak var statusLabel: UILabelComponent!
}
