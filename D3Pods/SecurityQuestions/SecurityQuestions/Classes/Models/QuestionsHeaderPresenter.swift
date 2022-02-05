//
//  QuestionsHeaderPresenter.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/11/18.
//

import Foundation
import UITableViewPresentation

struct QuestionsHeaderPresenter: UITableViewPresentable {
    func configure(cell: QuestionsHeaderView, at indexPath: IndexPath) {}
}

extension QuestionsHeaderPresenter: UITableViewNibRegistrable {
    var nib: UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: SecurityQuestionsBundle.bundle)
    }
}
