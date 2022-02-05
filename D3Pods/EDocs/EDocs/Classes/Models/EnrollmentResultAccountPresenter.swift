//
//  EnrollmentResultAccountPresenter.swift
//  EDocs
//
//  Created by Chris Carranza on 1/18/18.
//

import Foundation
import UITableViewPresentation

struct EnrollmentResultAccountPresenter: UITableViewPresentable, Equatable {
    let text: String
    
    func configure(cell: EnrollmentResultAccountCell, at indexPath: IndexPath) {
        cell.titleLabel.text = text
    }
}

extension EnrollmentResultAccountPresenter: UITableViewNibRegistrable {
    public var nib: UINib {
        return EDocsBundle.nib(name: cellReuseIdentifier)
    }
}
