//
//  EDocsLearnMoreViewController.swift
//  EDocs
//
//  Created by Branden Smith on 12/16/19.
//

import ComponentKit
import Localization
import Foundation
import UIKit
import UITableViewPresentation

final class EDocsLearnMoreViewController: UIViewControllerComponent {
    @IBOutlet weak var tableView: UITableViewComponent!

    private var dataSource: UITableViewPresentableDataSource!

    private lazy var infoItems: [LearnMoreInfoPresenter] = {
        var items: [LearnMoreInfoPresenter] = []

        // There are currently only five question and answers configured in l10n.
        // as the number of questions/answers increases. This code will need to
        // be adjusted accordingly. 
        for i in 1...5 {
            let question = l10nProvider.localize("edocs-prompt.learn-more.question-\(i)")
            let answer = l10nProvider.localize("edocs-prompt.learn-more.answer-\(i)")

            if !(question.isEmpty || answer.isEmpty) {
                items.append(
                    LearnMoreInfoPresenter(titleText: question, descriptionText: answer)
                )
            }
        }

        return items
    }()

    init(l10nProvider: L10nProvider, componentStyleProvider: ComponentStyleProvider) {
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "EDocsLearnMoreViewController",
            bundle: EDocsBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the overall view background color to the table view's
        // background color to avoid any weirdness outside of the safe area.
        view.backgroundColor = tableView.backgroundColor

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: l10nProvider.localize("edocs-prompt.learn-more.close"),
            style: .done,
            target: self,
            action: #selector(doneButtonTouched(_:))
        )

        self.title = l10nProvider.localize("edocs-prompt.learn-more.page-title")

        dataSource = UITableViewPresentableDataSource(tableView: tableView)

        dataSource.tableViewModel = UITableViewModel(
            sections: [
                UITableViewSection(rows: infoItems)
            ]
        )
    }

    @objc private func doneButtonTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
