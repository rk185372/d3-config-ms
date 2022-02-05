//
//  CardControlsViewController.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 4/5/18.
//

import D3Accounts
import Foundation
import Network
import ShimmeringData
import UIKit
import UITableViewPresentation
import Localization
import ComponentKit
import Views
import Analytics

final class CardControlsViewController: UIViewControllerComponent {
    @IBOutlet weak var tableView: UITableView!

    private var account: Account
    private var serviceItem: AccountsService!
    private var dataSource: UITableViewPresentableDataSource!
    private var cards: [Card] = []
    private var previousNavBarBarTintColor: UIColor?
    private var previousNavBarShadowImage: UIImage?
    private let buttonPresenterFactory: ButtonPresenterFactory

    // TODO: We will obviously be getting these colors from branding somehow
    // so we will need to figure that out when the time comes.
    private let backgroundColor: UIColor = UIColor(
        displayP3Red: 58.0 / 255.0,
        green: 125.0 / 255.0,
        blue: 159.0 / 255.0,
        alpha: 1.0
    )

    private var cardsHeader: AnyUITableViewHeaderFooterPresentable {
        return .init(CardControlsSectionHeaderPresenter(title: "Cards for \(account.name)"))
    }

    private var tosHeader: AnyUITableViewHeaderFooterPresentable {
        return .init(CardControlsSectionHeaderPresenter(title: "Terms and Conditions"))
    }

    init(l10nProvider: L10nProvider,
         componentStyleProvider: ComponentStyleProvider,
         account: Account,
         serviceItem: AccountsService,
         buttonPresenterFactory: ButtonPresenterFactory) {
        self.account = account
        self.serviceItem = serviceItem
        self.buttonPresenterFactory = buttonPresenterFactory
        super.init(
            l10nProvider: l10nProvider,
            componentStyleProvider: componentStyleProvider,
            nibName: String(describing: type(of: self)),
            bundle: AccountsPresentationBundle.bundle
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // We are making the contentInset 50.0 to add some padding from the navigation bar. This allows
        // us to stay more inline with the original design for this view.
        tableView.contentInset = UIEdgeInsets(top: 50.0, left: 0.0, bottom: 0.0, right: 0.0)

        // Store off the original shadow image so that when the user scrolls we can
        // put it back.
        previousNavBarShadowImage = navigationController?.navigationBar.shadowImage

        title = "Card Controls"

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange(_:)),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )

        // Setup the table view model and set it to the loading state using the ShimmeringCardControlsPresenter.
        dataSource = UITableViewPresentableDataSource(tableView: tableView, delegate: self)
        getCards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Navigation bar configuration.
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = backgroundColor

        // we are adding our own custom close button as the right bar button item of the navigation item.
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "CloseIcon", in: AccountsPresentationBundle.bundle, compatibleWith: nil),
            style: .plain,
            target: self,
            action: #selector(cancelButtonTouched(_:))
        )
    }

    private func getCards() {
        tableView.backgroundView = nil

        // Set the data model to the loading data model
        let shimmeringView = ShimmeringDataPresenter<ShimmeringCardControlsCell>(bundle: AccountsPresentationBundle.bundle)
        
        dataSource.tableViewModel = [
            UITableViewSection(rows: [shimmeringView], header: .presentable(cardsHeader))
        ]
        
        serviceItem
            .getCards(forAccountWithId: account.id)
            .subscribe({ [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .success(let cards):
                    self.cards = cards
                    self.updateViewController(with: cards)
                case .error:
                    self.dataSource.tableViewModel = []
                    let noItemsView = NoItemsView()
                    
                    // Style the no items view to fit this view controller.
                    noItemsView.subviews.first?.backgroundColor = self.backgroundColor
                    noItemsView.infoLabel.textColor = .white
                    noItemsView.tryAgainButton.setTitleColor(.white, for: .normal)
                    noItemsView.refreshIcon.tintColor = .white
                    noItemsView.infoLabel.text = "Failed to load cards associated with this account."
                    noItemsView.tryAgainButton.addTarget(
                        self,
                        action: #selector(self.retryButtonTouched(_:)),
                        for: .touchUpInside
                    )
                    
                    self.tableView.backgroundView = noItemsView
                }
            })
            .disposed(by: bag)
    }

    private func updateViewController(with cards: [Card]) {
        let cardPresenters = cards.map { (card: Card) -> AnyUITableViewPresentable in
            if view.traitCollection.preferredContentSizeCategory.isAccessibilitySize {
                return AnyUITableViewPresentable(ADACardPresenter(card: card, delegate: self))
            }

            return AnyUITableViewPresentable(CardPresenter(card: card, delegate: self))
        }

        // TODO: These (infoText and termsOfServiceInfoText) will obviously not be hard coded like this but we need to figure out
        // where this information is going to come from.
        let infoText = "If you have cards that you would like to control that are not displayed here, "
            + "please contact cutomer service."
        let info = [AnyUITableViewPresentable(InfoPresenter(info: infoText))]

        let termsOfServiceInfoText = "This party assumes no responsibility for accuracy, correctness "
            + "or content of the Disclousers provided on this website. You should not assume that the disclusures are continuously "
            + "updated or otherwise contain factual information. The Discllosures provided at this website are provided \"as is\" "
            + "and any warranty (express or implied), condition or other term of any kind including without limitation any warranty"
            + " of merchantability."

        let closeButton = buttonPresenterFactory.createButton(buttonTitle: "Close", style: .buttonOutlineOnSecondary) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }

        let tos = [
            AnyUITableViewPresentable(InfoPresenter(info: termsOfServiceInfoText)),
            AnyUITableViewPresentable(closeButton)
        ]

        self.dataSource.tableViewModel = [
            UITableViewSection(
                rows: cardPresenters + info,
                header: .presentable(cardsHeader)
            ),
            UITableViewSection(
                rows: tos,
                header: .presentable(tosHeader)
            )
        ]
    }

    @objc private func contentSizeCategoryDidChange(_ sender: Notification) {
        updateViewController(with: cards)
    }

    @objc private func retryButtonTouched(_ sender: UIButton) {
        getCards()
    }

    @objc private func cancelButtonTouched(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension CardControlsViewController: TrackableScreen {
    var screenName: String {
        return "Card Controls"
    }
}

extension CardControlsViewController: UITableViewPresentableDataSourceDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, presentable: AnyUITableViewPresentable) {}

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == -scrollView.contentInset.top {
            navigationController?.navigationBar.shadowImage = UIImage()
        } else {
            navigationController?.navigationBar.shadowImage = previousNavBarShadowImage
        }
    }
}

extension CardControlsViewController: CardPresenterDelegate {
    func toggleChanged(forSender sender: UISwitch, inPresenter presenter: CardPresenter) {
        if sender.isOn {
            activateCard(givenSwitch: sender, andPresenter: presenter)
        } else {
            deactivateCard(givenSwitch: sender, andPresenter: presenter)
        }
    }

    private func activateCard(givenSwitch uiSwitch: UISwitch, andPresenter presenter: CardPresenter) {
        presenter.startLoadingAnimation()
        
        serviceItem
            .activateCard(withId: presenter.card.id, forAccountWithId: account.id)
            .subscribe({ event in
                switch event {
                case .success(let card):
                    presenter.card.activated = card.activated
                case .error(let error):
                    // TODO: We still need to decide if we are showing and alert here or a "toast"
                    uiSwitch.isOn = false
                    print(error)
                }

                presenter.stopLoadingAnimation()
            })
            .disposed(by: bag)
    }

    private func deactivateCard(givenSwitch uiSwitch: UISwitch, andPresenter presenter: CardPresenter) {
        presenter.startLoadingAnimation()
        
        serviceItem
            .deactivateCard(withId: presenter.card.id, forAccountWithId: account.id)
            .subscribe({ event in
                switch event {
                case .success(let card):
                    presenter.card.activated = card.activated
                case .error(let error):
                    // TODO: We still need to decide if we are showing and alert here or a "toast"
                    uiSwitch.isOn = true
                    print(error)
                }
                
                presenter.stopLoadingAnimation()
            })
            .disposed(by: bag)
    }
}
