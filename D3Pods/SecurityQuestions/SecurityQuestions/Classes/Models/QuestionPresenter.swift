//
//  QuestionPresenter.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/6/18.
//

import Foundation
import UIKit
import UITableViewPresentation

struct QuestionPresenter: UITableViewPresentable {
    let question: String

    func configure(cell: QuestionCell, at indexPath: IndexPath) {
        cell.questionLabel.text = question
    }
}

extension QuestionPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: SecurityQuestionsBundle.bundle)
    }
}
