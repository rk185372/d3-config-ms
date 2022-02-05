//
//  AccountTypeHolder.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 1/23/19.
//

import D3Accounts
import Foundation

struct AccountTypeHolder {
    let choices: [RawAccountProduct]
    var selectedItem: RawAccountProduct?

    init(choices: [RawAccountProduct]) {
        self.choices = choices
        self.selectedItem = choices.first
    }
}
