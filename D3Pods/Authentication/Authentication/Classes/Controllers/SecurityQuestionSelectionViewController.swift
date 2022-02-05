//
//  SecurityQuestionSelectionViewController.swift
//  Authentication
//
//  Created by Branden Smith on 7/24/18.
//

import ComponentKit
import Foundation
import Localization
import UIKit
import UITableViewPresentation

protocol SecurityQuestionSelectionViewControllerDelegate: class {
    func questionSelectionViewController(_: SecurityQuestionSelectionViewController, doneButtonTouched button: UIBarButtonItem)
    func questionSelectionViewController(_: SecurityQuestionSelectionViewController,
                                         didSelectNewQuestion question: String,
                                         forChallengePresenter challengePresenter: ChallengeNewQuestionItemPresenter)
}

final class SecurityQuestionSelectionViewController: UIViewControllerComponent {
    @IBOutlet weak var tableView: UITableView!
    
    private let challengePresenter: ChallengeNewQuestionItemPresenter
    private var dataSource: UITableViewPresentableDataSource!

    weak var delegate: SecurityQuestionSelectionViewControllerDelegate?

    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                challengePresenter: ChallengeNewQuestionItemPresenter,
                delegate: SecurityQuestionSelectionViewControllerDelegate) {
        
        self.challengePresenter = challengePresenter
        self.delegate = delegate

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "SecurityQuestionSelectionViewController",
            bundle: AuthenticationBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTouched(_:))
        )

        dataSource = UITableViewPresentableDataSource(tableView: tableView, delegate: self)

        dataSource.tableViewModel = [
            UITableViewSection(
                rows: challengePresenter
                    .challenge
                    .questions
                    .map { AnyUITableViewPresentable(SecurityQuestionPresenter(question: $0)) }
            )
        ]

    }

    @objc private func doneButtonTouched(_ button: UIBarButtonItem) {
        delegate?.questionSelectionViewController(self, doneButtonTouched: button)
    }
}

extension SecurityQuestionSelectionViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        if let question = (presentable.base as? SecurityQuestionPresenter)?.question {
            delegate?.questionSelectionViewController(self,
                                                         didSelectNewQuestion: question,
                                                         forChallengePresenter: challengePresenter)
        }
    }
}
