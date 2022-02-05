//
//  QuestionSelectionViewController.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/6/18.
//

import ComponentKit
import Foundation
import Localization
import UIKit
import UITableViewPresentation
import Analytics

final class QuestionSelectionViewController: UIViewControllerComponent {
    private let questions: [String]
    private let onSelect: (String) -> Void

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoImageView: UIImageViewComponent!
    @IBOutlet weak var closeButton: UIButton!

    private var dataSource: UITableViewPresentableDataSource?

    init(componentSytleProvider: ComponentStyleProvider,
         l10nProvider: L10nProvider,
         questions: [String],
         onSelect: @escaping (String) -> Void) {
        self.questions = questions
        self.onSelect = onSelect

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentSytleProvider,
            nibName: "QuestionSelectionViewController",
            bundle: SecurityQuestionsBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.image = UIImage(named: "FullLogo")
        closeButton.setImage(UIImage(named: "CloseButton"), for: .normal)

        let model: UITableViewModel = [
            UITableViewSection(rows: [QuestionsHeaderPresenter()]),
            UITableViewSection(rows: questions.map { QuestionPresenter(question: $0) })
        ]
        dataSource = UITableViewPresentableDataSource(tableView: tableView, delegate: self, tableViewModel: model)
    }

    @IBAction func closeButtonTouched(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension QuestionSelectionViewController: TrackableScreen {
    var screenName: String {
        return "PostAuth/SetupSecurityQuestion/Chooser"
    }
}

extension QuestionSelectionViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {
        if let selection = (presentable.base as? QuestionPresenter)?.question {
            onSelect(selection)
            dismiss(animated: true, completion: nil)
        }
    }
}
