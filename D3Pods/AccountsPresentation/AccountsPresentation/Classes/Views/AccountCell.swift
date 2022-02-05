//
//  AccountCell.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/12/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import UIKit
import ComponentKit

public class AccountCell: UITableViewCell {
    @IBOutlet public weak var accountCircle: AccountCircle!
    @IBOutlet public weak var nameLabel: UILabelComponent!
    @IBOutlet public weak var accountNumberLabel: UILabelComponent!
    @IBOutlet public weak var balanceLabel: UILabelComponent!
    @IBOutlet public weak var balanceTypeLabel: UILabelComponent!
}
