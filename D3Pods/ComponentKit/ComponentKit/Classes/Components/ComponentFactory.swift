//
//  ComponentFactory.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/9/18.
//

import Foundation
import Localization

public final class ComponentFactory {
    private let config: ComponentConfig

    public init(config: ComponentConfig) {
        self.config = config
    }
    
    public func createButton(style: ButtonStyleKey?, l10nKey: String?) -> UIButtonComponent {
        let button = UIButtonComponent(l10nProvider: config.l10nProvider, componentStyleProvider: config.componentStyleProvider)
        button.style = style?.rawValue
        button.l10nKey = l10nKey
        button.configureComponent()
        return button
    }
    
    public func createView(style: ViewStyleKey?) -> UIViewComponent {
        let view = UIViewComponent(componentStyleProvider: config.componentStyleProvider)
        view.style = style?.rawValue
        view.configureComponent()
        return view
    }
    
    public func createTabBarController(style: TabBarControllerStyleKey) -> UITabBarControllerComponent {
        return UITabBarControllerComponent(
            l10nProvider: config.l10nProvider,
            componentStyleProvider: config.componentStyleProvider,
            styleKey: style
        )
    }
}
