//
//  ADAAccountPresenter.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 3/5/18.
//

import Foundation
import UITableViewPresentation
import D3Accounts

final class ADAAccountPresenter: AccountPresenter {
    override var cellReuseIdentifier: String {
        return "ADAAccountCell"
    }
}
