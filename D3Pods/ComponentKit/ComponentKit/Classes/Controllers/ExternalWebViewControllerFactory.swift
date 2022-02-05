//
//  ExternalWebViewControllerFactory.swift
//  ComponentKit
//
//  Created by Andrew Watt on 8/31/18.
//

import Foundation
import Utilities

public final class ExternalWebViewControllerFactory {
    private let config: ComponentConfig
    private let device: Device
    private let urlOpener: URLOpener
    
    public init(config: ComponentConfig,
                device: Device,
                urlOpener: URLOpener) {
        self.config = config
        self.device = device
        self.urlOpener = urlOpener
    }
    
    public func create(destination: ExternalWebViewController.WebDestination,
                       navigationConfig: ExternalWebViewNavigationConfig = .init(navigable: true),
                       cookies: [HTTPCookie] = [],
                       delegate: ExternalWebViewControllerDelegate? = nil) -> UIViewController {
        let viewController = ExternalWebViewController(
            config: config,
            destination: destination,
            device: device,
            navigationConfig: navigationConfig,
            urlOpener: urlOpener,
            cookies: cookies
        )
        viewController.delegate = delegate
        return UINavigationControllerComponent(rootViewController: viewController)
    }
}
