//
//  TransactionRowController.swift
//  D3 Banking
//
//  Created by Branden Smith on 10/22/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import WatchKit

final class TransactionRowController: NSObject {
    @IBOutlet var monthLabel: WKInterfaceLabel!
    @IBOutlet var dayLabel: WKInterfaceLabel!
    @IBOutlet var transactionDescriptionLabel: WKInterfaceLabel!
    @IBOutlet var amountLabel: WKInterfaceLabel!
    @IBOutlet var accountLabel: WKInterfaceLabel!
}
