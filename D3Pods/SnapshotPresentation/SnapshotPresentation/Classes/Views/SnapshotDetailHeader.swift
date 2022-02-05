//
//  SnapshotDetailHeader.swift
//  SnapshotPresentation
//
//  Created by Elvin Bearden on 8/19/20.
//

import UIKit
import DependencyContainerExtension
import ComponentKit
import Snapshot
import Localization

class SnapshotDetailHeader: UIView, NibInjectable {
    @IBOutlet private weak var accountNameLabel: UILabel!
    @IBOutlet private weak var accountNumberLabel: UILabel!
    @IBOutlet private weak var availableBalanceLabel: UILabel!
    @IBOutlet private weak var availableBalanceDescriptionLabel: UILabel!
    @IBOutlet private weak var currentBalanceLabel: UILabel!
    @IBOutlet private weak var currentBalanceDescriptionLabel: UILabel!
    @IBOutlet private weak var priorDayBalanceLabel: UILabel!
    @IBOutlet private weak var priorDayBalanceDescriptionLabel: UILabel!
    @IBOutlet private weak var availableBalanceView: UIView!
    @IBOutlet private weak var currentBalanceView: UIView!
    @IBOutlet private weak var priorDayBalanceView: UIView!
    @IBOutlet weak var tooltipLabel: UILabel!

    private var l10nProvider: L10nProvider!

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    public func configure(account: Snapshot.Account, l10nProvider: L10nProvider) {
        self.l10nProvider = l10nProvider
        accountNameLabel.text = account.name
        accountNumberLabel.text = account.number

        if let balance = account.balance {
            availableBalanceLabel.text = balance.formatted(currencyCode: account.currencyCode)
            availableBalanceDescriptionLabel.attributedText = createDescriptionAttributedString(
                fontSize: availableBalanceDescriptionLabel.font.pointSize,
                balance: balance
            )
            tooltipLabel.isHidden = true
        } else {
            availableBalanceView.isHidden = true
            tooltipLabel.isHidden = false
            tooltipLabel.text = l10nProvider.localize("launchPage.snapshot.detail.enable-balance")
        }

        if let balance2 = account.balance2 {
            currentBalanceView.isHidden = false
            currentBalanceLabel.text = balance2.formatted(currencyCode: account.currencyCode)
            currentBalanceDescriptionLabel.attributedText =
                createDescriptionAttributedString(
                    fontSize: currentBalanceDescriptionLabel.font.pointSize,
                    balance: balance2
            )
        } else {
            currentBalanceView.isHidden = true
        }

        if let balance3 = account.balance3 {
            priorDayBalanceView.isHidden = false
            priorDayBalanceLabel.text = balance3.formatted(currencyCode: account.currencyCode)
            priorDayBalanceDescriptionLabel.attributedText = createDescriptionAttributedString(
                fontSize: priorDayBalanceDescriptionLabel.font.pointSize,
                balance: balance3
            )
        } else {
            priorDayBalanceView.isHidden = true
        }
    }

    private func createDescriptionAttributedString(fontSize: CGFloat,
                                                   balance: Snapshot.AccountBalance) -> NSAttributedString {

        let typeKey = balance.type.l10nKey

        let accountType = l10nProvider.localize(typeKey)
        var asOfDateString = ""
        if let date = balance.asOfDate {
            let dateString = date.longStyleStringExcludingTime
            asOfDateString = l10nProvider.localize(
                "launchPage.snapshot.detail.balance-date",
                parameterMap: [
                    "date": dateString
            ])
        }
        let balanceDescription = l10nProvider.localize(
            "launchPage.snapshot.detail.balance-description",
            parameterMap: [
                "accountType": accountType,
                "balanceDate": asOfDateString
        ])

        let attributed = NSMutableAttributedString(string: balanceDescription)
        let boldRange = (balanceDescription as NSString).range(of: l10nProvider.localize(typeKey))
        attributed.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: fontSize), range: boldRange)
        return attributed
    }

    private func loadNib() {
        guard let view = SnapshotPresentationBundle.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?
            .first as? UIView else { return }

        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.makeMatch(view: self)
    }

    func injectDependenciesFrom(_ container: DependencyContainer) throws {
    }
}
