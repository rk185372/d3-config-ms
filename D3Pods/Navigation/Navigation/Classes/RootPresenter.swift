//
//  Presenting.swift
//  Utilities
//
//  Created by Andrew Watt on 7/11/18.
//

import Foundation

public enum RootView: Equatable {
    case initializing(suppressAutoPrompt: Bool)
    case featureTour(suppressAutoPrompt: Bool)
    case authenticating(suppressAutoPrompt: Bool)
    case dashboard
    case maintenance(message: String?)
    case loggingOut
}

extension RootView {
    public static func == (lhs: RootView, rhs: RootView) -> Bool {
        switch (lhs, rhs) {
        case (.initializing(let leftSuppressAutoPrompt), .initializing(let rightSuppressAutoPrompt)):
            return leftSuppressAutoPrompt == rightSuppressAutoPrompt
        case (.featureTour(let leftSuppressAutoPrompt), .featureTour(let rightSuppressAutoPrompt)):
            return leftSuppressAutoPrompt == rightSuppressAutoPrompt
        case (.authenticating(let leftSuppressAutoPrompt), .authenticating(let rightSuppressAutoPrompt)):
            return leftSuppressAutoPrompt == rightSuppressAutoPrompt
        case (.dashboard, .dashboard):
            return true
        case (.maintenance(let leftMessage), .maintenance(let rightMessage)):
            return leftMessage == rightMessage
        case (.loggingOut, .loggingOut):
            return true
        default:
            return false
        }
    }
}

public protocol RootPresenter {
    /// Present a specific view
    func present(view: RootView)

    /// Present whatever view follows `from` in normal program flow.
    func advance(from: RootView)
}

public protocol RootPresentable {
    func createViewController(presentingFrom presenter: RootPresenter) -> UIViewController
}
