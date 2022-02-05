//
//  StopRangeOfPaymentsHistoryCell.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/20/18.
//

import Foundation
import UIKit
import ComponentKit

final class StopRangeOfPaymentsHistoryCell: UITableViewCell {
    @IBOutlet weak var expirationDateLabel: UILabelComponent!
    @IBOutlet weak var amountFromLabel: UILabelComponent!
    @IBOutlet weak var amountToLabel: UILabelComponent!
    @IBOutlet weak var reasonLabel: UILabelComponent!
    @IBOutlet weak var checkFromLabel: UILabelComponent!
    @IBOutlet weak var checkToLabel: UILabelComponent!
    @IBOutlet weak var payeeLabel: UILabelComponent!
    @IBOutlet weak var statusLabel: UILabelComponent!
}
