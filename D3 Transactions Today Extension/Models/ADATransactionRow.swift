//
//  ADATransactionRow.swift
//  D3 Transactions Today Extension
//
//  Created by Branden Smith on 2/25/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation

final class ADATransactionRow: TransactionRow {
    override var cellReuseIdentifier: String {
        return "ADATransactionCell"
    }

    override var dateFormatter: DateFormatter {
        return DateFormatter.abbreviatedMonthAndDay
    }
}
