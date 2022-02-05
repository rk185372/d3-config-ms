//
//  BuildInfoViewController.swift
//  Pods
//
//  Created by Branden Smith on 12/14/18.
//

import ComponentKit
import Foundation
import Localization
import Logging
import MessageUI
import PresenterKit
import RxSwift
import UIKit
import UITableViewPresentation
import Utilities
import Web

public final class BuildInfoViewController: UIViewControllerComponent {
    @IBOutlet weak var tableView: UITableView!

    private var dataSource: UITableViewPresentableDataSource?

    private let themeService: ThemeService
    private let l10nService: L10nService
    private let buildInfoScreenState: BuildInfoScreenState

    private let buildInfoItemPresenters: [BuildInfoItemPresenter] = {
        return BuildInfoItem.defaultItems.map {
            BuildInfoItemPresenter(infoItem: $0)
        }
    }()

    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         themeService: ThemeService,
         l10nService: L10nService,
         buildInfoScreenState: BuildInfoScreenState) {
        self.themeService = themeService
        self.l10nService = l10nService
        self.buildInfoScreenState = buildInfoScreenState

        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: "BuildInfoViewController",
            bundle: BuildInfoScreenBundle.bundle
        )
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Build Info"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneButtonTouched(_:))
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Email",
            style: .plain,
            target: self,
            action: #selector(emailButtonTouched(_:))
        )

        setupTableView()
    }

    private func setupTableView() {
        let model: UITableViewModel = [
            UITableViewSection(rows: buildInfoItemPresenters),
            UITableViewSection(rows: [
                SwitchPresenter(
                    title: "Translates L10n",
                    initialState: buildInfoScreenState.translatesL10n,
                    toggleListener: { [weak self] uiSwitch in
                        // Calling swizzleLocalize here will continuously swap the implmentations
                        // of the localize method in l10n. This means that on the first call it
                        // will replace the real implementation with the swizzled implementation
                        // the next call will switch it back and so on and so forth.
                        L10n.swizzleLocalize()
                        WebClient.swizzleNavigationURL()
                        self?.buildInfoScreenState.translatesL10n = uiSwitch.isOn
                }),
                SwitchPresenter(
                    title: "Uses Local Extensions",
                    initialState: buildInfoScreenState.usesLocalExtensions,
                    toggleListener: { [weak self] uiSwitch in
                        WebViewExtensionsCache.swizzleGetEnabledExtensions()
                        self?.buildInfoScreenState.usesLocalExtensions = uiSwitch.isOn
                })
            ]),
            UITableViewSection(
                rows: [
                    ButtonPresenter(
                        buttonTitle: "Update Theme",
                        style: .buttonCta,
                        clickListener: { [unowned self] buttonComponent in
                            self.beginLoading(fromButton: buttonComponent)
                            self.themeService
                                .getTheme()
                                .subscribe({ [weak self] result in
                                    switch result {
                                    case .success(let themeResponseData):
                                        do {
                                            guard
                                                let themeResponseJSON = try
                                                    JSONSerialization.jsonObject(with: themeResponseData, options: .allowFragments)
                                                    as? [AnyHashable: Any],
                                                let themeJSON = themeResponseJSON["overrides"] as? [String: Any]
                                                else {
                                                    self?.showUpdateThemeError()
                                                    return
                                            }

                                            let updateThemeNotification = Notification(
                                                name: .updatedThemeNotification,
                                                object: nil,
                                                userInfo: themeJSON
                                            )

                                            DispatchQueue.main.async {
                                                NotificationCenter.default.post(updateThemeNotification)
                                            }
                                        } catch {
                                            self?.showUpdateThemeError()
                                        }
                                    case .error:
                                        self?.showUpdateThemeError()
                                    }

                                    self?.cancelables.cancel()
                                })
                                .disposed(by: self.bag)
                    }),
                    ButtonPresenter(
                        buttonTitle: "Update L10n",
                        style: .buttonCta,
                        clickListener: { [unowned self] buttonComponent in
                            self.beginLoading(fromButton: buttonComponent)
                            self.l10nService
                            .getL10n()
                            .subscribe({ [weak self] result in
                                switch result {
                                case .success(let l10nData):
                                    do {
                                        let l10nJSON =
                                            try JSONSerialization.jsonObject(with: l10nData, options: .allowFragments) as? [String: Any]

                                        DispatchQueue.main.async {
                                            NotificationCenter.default.post(
                                                name: .updatedL10nNotification,
                                                object: nil,
                                                userInfo: l10nJSON
                                            )
                                        }
                                    } catch {
                                        self?.showUpdateL10nError()
                                    }
                                case .error:
                                    self?.showUpdateL10nError()
                                }

                                self?.cancelables.cancel()
                            })
                            .disposed(by: self.bag)
                    })
                ]
            )
        ]

        dataSource = UITableViewPresentableDataSource(tableView: tableView, tableViewModel: model)
    }

    private func getMessageText() -> String {
        var message = ""

        for (index, presenter) in buildInfoItemPresenters.enumerated() {
            message += presenter.toString()

            if index != buildInfoItemPresenters.count - 1 {
                message += "\n"
            }
        }

        return message
    }

    private func showUpdateThemeError() {
        let alert = UIAlertController(
            title: "Error",
            message: "There was a problem updating the theme.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    private func showUpdateL10nError() {
        let alert = UIAlertController(
            title: "Error",
            message: "There was an error updating the L10n.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    @objc private func doneButtonTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func emailButtonTouched(_ sender: UIBarButtonItem) {
        let vc = MFMailComposeViewController()

        vc.mailComposeDelegate = self
        vc.setMessageBody(getMessageText(), isHTML: false)

        present(vc, animated: true, completion: nil)
    }
}

extension BuildInfoViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .failed {
            log.error("BuildInfo email failed to send. Error: \(String(describing: error))")
        }

        controller.dismiss(animated: true, completion: nil)
    }
}
