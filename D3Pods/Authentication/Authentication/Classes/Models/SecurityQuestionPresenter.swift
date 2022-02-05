//
//  SecurityQuestionPresenter.swift
//  Authentication
//
//  Created by Branden Smith on 7/24/18.
//

import Foundation
import UITableViewPresentation
import Utilities

class SecurityQuestionPresenter: UITableViewPresentable {
    let question: String

    var cellReuseIdentifier: String {
        return String(describing: TableViewCell.self)
    }

    init(question: String) {
        self.question = question
    }

    func configure(cell: SecurityQuestionCell, at indexPath: IndexPath) {
        cell.label.text = question
    }
}

extension SecurityQuestionPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: AuthenticationBundle.bundle)
    }
}

extension SecurityQuestionPresenter: Equatable {
    static func ==(lhs: SecurityQuestionPresenter, rhs: SecurityQuestionPresenter) -> Bool {
        guard lhs.question == rhs.question else { return false }

        return true
    }
}
