//
//  FlowAuthPresenter.swift
//  Authentication
//
//  Created by Andrew Watt on 8/15/18.
//

import Authentication
import ComponentKit
import Logging
import Navigation
import RxSwift
import Snapshot
import SnapshotPresentation
import UIKit
import Utilities

public final class FlowAuthPresenter: AuthPresenter {
    private let snapshotViewControllerFactory: SnapshotViewControllerFactory
    private let locationsViewControllerFactory: ViewControllerFactory
    private let urlOpener: URLOpener
    private let externalWebViewControllerFactory: ExternalWebViewControllerFactory
    private let pdfPresenter: PDFPresenter
    private let authDialogControllerFactory: AuthDialogControllerFactory
    private let bag = DisposeBag()

    public weak var delegate: AuthPresenterDelegate?

    public init(snapshotViewControllerFactory: SnapshotViewControllerFactory,
                locationsViewControllerFactory: ViewControllerFactory,
                urlOpener: URLOpener,
                pdfPresenter: PDFPresenter,
                externalWebViewControllerFactory: ExternalWebViewControllerFactory,
                authDialogControllerFactory: AuthDialogControllerFactory) {
        self.snapshotViewControllerFactory = snapshotViewControllerFactory
        self.locationsViewControllerFactory = locationsViewControllerFactory
        self.urlOpener = urlOpener
        self.pdfPresenter = pdfPresenter
        self.externalWebViewControllerFactory = externalWebViewControllerFactory
        self.authDialogControllerFactory = authDialogControllerFactory
    }

    public func presentSnapshot(withToken token: String, from presentingViewController: UIViewController) {
        let viewController = snapshotViewControllerFactory.create(token: token)
        let navigationController = UINavigationController(rootViewController: viewController)
        presentingViewController.present(navigationController, animated: true)
    }

    public func presentSelfEnrollment(url: URL, from presentingViewController: UIViewController) {
        let config = ExternalWebViewNavigationConfig(navigable: false)
        let viewController = externalWebViewControllerFactory.create(
            destination: .url(url),
            navigationConfig: config,
            delegate: self
        )
        presentingViewController.present(viewController, animated: true)
    }

    public func presentHelpView(url: URL?, from presentingViewController: UIViewController) {
        guard let urlString = url else { return }
        let viewController = externalWebViewControllerFactory.create(
            destination: .url(urlString),
            delegate: self
        )
        presentingViewController.present(viewController, animated: true)
    }

    public func present(launchPageItem: LaunchPageItem, from presentingViewController: UIViewController) {
        switch launchPageItem.type {
        case .locations:
            let viewController = locationsViewControllerFactory.create()
            presentingViewController.present(viewController, animated: true)

        case .phone(let number):
            urlOpener.call(phoneNumber: number)

        case .webView(let url):
            if url.lastPathComponent.hasSuffix(".pdf") {
                presentPDF(atURL: url, fromViewController: presentingViewController)
            } else {
                let viewController = externalWebViewControllerFactory.create(
                    destination: .url(url),
                    delegate: self
                )
                presentingViewController.present(viewController, animated: true)
            }
        }
    }

    public func present(dialogType: AuthDialogType, from presentingViewController: UIViewController) {
        switch dialogType {
        case .enrollment, .forgotUsernamePassword:
            let view = authDialogControllerFactory.create(
                type: dialogType,
                delegate: self
            )
            presentingViewController.present(view, animated: true)
        case .toolTip:
            let view = authDialogControllerFactory.create(type: .toolTip)
            view.modalPresentationStyle = .overCurrentContext
            view.modalTransitionStyle = .crossDissolve
            presentingViewController.present(view, animated: true)
        }
    }

    private func presentPDF(atURL url: URL, fromViewController presentingViewController: UIViewController) {
        pdfPresenter
            .presentPDF(atURL: url, fromViewController: presentingViewController)
            .subscribe(onError: { (error) in
                log.error("Error presenting PDF: \(error)", context: error)
            })
            .disposed(by: bag)
    }
}

extension FlowAuthPresenter: ExternalWebViewControllerDelegate {
    public func externalWebViewController(_ viewController: ExternalWebViewController, navigatingToPDFAtURL url: URL) {
        self.presentPDF(atURL: url, fromViewController: viewController)
    }

    public func externalWebViewController(_ viewController: ExternalWebViewController,
                                          didReceiveData data: [String: String]) {
        delegate?.presenter(self, didReceiveData: data)
    }
}

extension FlowAuthPresenter: AuthDialogViewControllerDelegate {
    public func authDialogViewController(_ viewController: AuthDialogViewController,
                                         type: AuthDialogType,
                                         didTap url: URL?) {
        self.presentHelpView(url: url, from: viewController)
    }
}
