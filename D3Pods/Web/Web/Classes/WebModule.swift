//
//  WebModule.swift
//  Web
//
//  Created by Branden Smith on 1/30/19.
//

import Dip
import DependencyContainerExtension
import Foundation

public final class WebModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register {
            WebViewServiceItem(client: $0) as WebViewService
        }

        container.register(.singleton) {
            WebViewExtensionsCache(serviceItem: $0, localExtensionsFilename: "extension", bundle: WebBundle.bundle)
        }
    }
}
