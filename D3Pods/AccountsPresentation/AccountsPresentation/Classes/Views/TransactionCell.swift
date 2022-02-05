//
//  TransactionCell.swift
//  D3 Banking
//
//  Created by Chris Carranza on 5/18/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import UIKit
import ComponentKit

final class TransactionCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabelComponent!
    @IBOutlet weak var amountLabel: UILabelComponent!
    @IBOutlet weak var categoryLabel: UILabelComponent!
    @IBOutlet weak var balanceLabel: UILabelComponent!

}
