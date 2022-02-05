//
//  AuthDialogViewController.swift
//  Authentication
//
//  Created by Jose Torres on 3/16/21.
//

import Foundation
import ComponentKit

public enum AuthDialogType {
    case toolTip
    case forgotUsernamePassword(url: URL?)
    case enrollment(url: URL?)
}

public protocol AuthDialogViewControllerDelegate: class {
    func authDialogViewController(_: AuthDialogViewController, type: AuthDialogType, didTap url: URL?)
}

public class AuthDialogViewController: UIViewControllerComponent {
    
}
