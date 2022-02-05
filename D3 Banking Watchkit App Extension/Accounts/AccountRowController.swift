//
//  AccountRowController.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/23/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import WatchKit

final class AccountRowController: NSObject {
    @IBOutlet weak var accountName: WKInterfaceLabel!
    @IBOutlet weak var accountBalance: WKInterfaceLabel!
    @IBOutlet var accountTypeImage: WKInterfaceImage!
}
