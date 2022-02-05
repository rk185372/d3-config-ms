//
//  ChallengeLinkButtonItemsPresenter.swift
//  Authentication
//
//  Created by Elvin Bearden on 11/27/20.
//

import Foundation
import ComponentKit
import RxSwift
import Utilities
import ViewPresentable

protocol ChallengeLinkButtonItemsPresenterDelegate: class {
    func present(url: URL)
    func present(dialog: AuthDialogType)
}

final class ChallengeLinkButtonItemsPresenter: ViewPresentable {
    let challenge: ChallengeLinkButtonItems
    let componentStyleProvider: ComponentStyleProvider

    private let bag = DisposeBag()

    weak var delegate: ChallengeLinkButtonItemsPresenterDelegate?

    init(challenge: ChallengeLinkButtonItems, componentStyleProvider: ComponentStyleProvider) {
        self.challenge = challenge
        self.componentStyleProvider = componentStyleProvider
    }

    func createView() -> ChallengeLinkButtonsView {
        return AuthenticationBundle.bundle.loadNibNamed(
            "ChallengeLinkButtonsView",
            owner: nil,
            options: nil
        )!.first as! ChallengeLinkButtonsView
    }

    func configure(view: ChallengeLinkButtonsView) {
        for (index, linkButton) in challenge.buttons.enumerated() {
            let button = UIButton()
            button.setTitle(linkButton.title, for: .normal)

            view.stackView.addArrangedSubview(button)

            button.rx.tap.bind {
                if let dialog = linkButton.buttonDialog, dialog.type == .businessLoginHelpDialog {
                    self.delegate?.present(dialog: .forgotUsernamePassword(url: dialog.url))
                } else if let url = linkButton.url {
                    self.delegate?.present(url: url)
                }
            }.disposed(by: bag)

            if index < challenge.buttons.count {
                let spacer = UIView()
                spacer.backgroundColor = .systemRed
                view.stackView.addArrangedSubview(spacer)
                spacer.snp.makeConstraints { (make) in
                    make.width.equalTo(2)
                    make.height.equalTo(10)
                }
                //To resolve challenge button spaces in the Business login page
                //As business only has one link button coming we need to add the spacer and then hide it.
                if index == challenge.buttons.count - 1 {
                    spacer.isHidden = true
                }                
            }
        }

        view.stackView.configureComponent()
    }
}

extension ChallengeLinkButtonItemsPresenter: Equatable {
    static func == (lhs: ChallengeLinkButtonItemsPresenter, rhs: ChallengeLinkButtonItemsPresenter) -> Bool {
        return lhs.challenge.buttons.map { $0.title }
            == rhs.challenge.buttons.map { $0.title }
    }
}
