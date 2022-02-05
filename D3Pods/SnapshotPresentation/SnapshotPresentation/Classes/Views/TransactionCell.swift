//
//  TransactionCell.swift
//  Snapshot
//
//  Created by Andrew Watt on 8/17/18.
//

import UIKit
import ComponentKit

class TransactionCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabelComponent!
    @IBOutlet weak var descriptionLabel: UILabelComponent!
    @IBOutlet weak var amountLabel: UILabelComponent!
    @IBOutlet weak var statusLabel: UILabelComponent!
}
