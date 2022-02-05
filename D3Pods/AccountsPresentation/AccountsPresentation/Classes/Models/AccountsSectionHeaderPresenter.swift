//
//  AccountsSectionHeaderPresenter.swift
//  D3 Banking
//
//  Created by Chris Carranza on 5/8/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import UITableViewPresentation
import Branding

public class AccountsSectionHeaderPresenter: UITableViewHeaderFooterPresentable {
    let title: String

    public var viewReuseIdentifier: String {
        return "AccountsSectionHeader"
    }
    
    public init(title: String) {
        self.title = title
    }
    
    public func configure(view: AccountsSectionHeader, for section: Int) {
        view.titleLabel.text = title
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        view.backgroundView = bgView
    }
}

extension AccountsSectionHeaderPresenter: UITableViewHeaderFooterNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: viewReuseIdentifier, bundle: AccountsPresentationBundle.bundle)
    }
}

extension AccountsSectionHeaderPresenter: Equatable {
    public static func ==(lhs: AccountsSectionHeaderPresenter, rhs: AccountsSectionHeaderPresenter) -> Bool {
        guard lhs.title == rhs.title else { return true }
        
        return true
    }
}
