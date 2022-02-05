//
//  MessagesViewControllerFactory.swift
//  Web
//
//  Created by Andrew Watt on 7/2/18.
//

import UIKit
import Utilities
import Localization
import Logging
import ComponentKit
import Network
import Permissions
import Session
import RxSwift

public final class WebComponentViewControllerFactory: ViewControllerFactory {
    let l10NProvider: L10nProvider
    let componentStyleProvider: ComponentStyleProvider
    let model: WebComponentModel
    let permissionsManager: PermissionsManager
    let webViewControllerFactory: WebViewControllerFactory
    let userSession: UserSession
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                permissionsManager: PermissionsManager,
                webViewControllerFactory: WebViewControllerFactory,
                navigation: WebComponentNavigation,
                userSession: UserSession) throws {
        self.l10NProvider = l10nProvider
        self.componentStyleProvider = componentStyleProvider
        self.permissionsManager = permissionsManager
        self.webViewControllerFactory = webViewControllerFactory
        self.userSession = userSession
        
        self.model = WebComponentModel(navigation: navigation)
    }
    
    public func create() -> UIViewController {
        let accessibleItems = model.navigation.items.filter { permissionsManager.isAccessible(feature: $0.feature) }
        if accessibleItems.count <= 1 {
            do {
                let componentPath = WebComponentPath(
                    path: accessibleItems.first?.path ?? model.navigation.path,
                    showsUserProfile: model.navigation.showsUserProfile
                )

                let viewController = try webViewControllerFactory.create(componentPath: componentPath, isRootComponent: true)

                return UINavigationControllerComponent(rootViewController: viewController)
            } catch {
                log.error("Unable to create web view controller: \(error)", context: error)
                fatalError("\(error)")
            }
        } else {
            let viewController = WebComponentViewController(
                l10nProvider: l10NProvider,
                componentStyleProvider: componentStyleProvider,
                webViewControllerFactory: webViewControllerFactory,
                permissionsManager: permissionsManager,
                model: model,
                userSession: userSession
            )
            return UINavigationControllerComponent(rootViewController: viewController)
        }
    }
}

extension WebComponentViewControllerFactory: Permissioned {
    public var feature: Feature {
        return model.navigation.feature
    }
}
