//
//  AuthPresenter.swift
//  Authentication
//
//  Created by Andrew Watt on 8/15/18.
//

import UIKit
import Navigation

public protocol AuthPresenterDelegate: class {
    func presenter(_ presenter: AuthPresenter, didReceiveData data: [String: String])
}

public protocol AuthPresenter: class {

    var delegate: AuthPresenterDelegate? { get set }

    func presentSnapshot(withToken: String, from: UIViewController)
    func presentSelfEnrollment(url: URL, from: UIViewController)
    func presentHelpView(url: URL?, from: UIViewController)
    func present(launchPageItem: LaunchPageItem, from: UIViewController)
    func present(dialogType: AuthDialogType, from: UIViewController)
}
