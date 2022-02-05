//
//  RDCDepositTransactionHeaderPresenter.swift
//  Pods
//
//  Created by Chris Pflepsen on 9/2/18.
//

import Foundation
import Utilities
import UITableViewPresentation

struct RDCDepositTransactionHeaderPresenter: UITableViewHeaderFooterPresentable, Equatable {
    
    let title: String
    
    init(dateString: String) {
        title = dateString
    }
    
    func configure(view: RDCDepositTransactionHeader, for section: Int) {        
        view.titleLabel.text = title
    }
}

extension RDCDepositTransactionHeaderPresenter: UITableViewHeaderFooterNibRegistrable {
    public var nib: UINib {
        return UINib(nibName: viewReuseIdentifier, bundle: RDCBundle.bundle)
    }
}
