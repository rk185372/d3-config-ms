//
//  API+WebView.swift
//  Web
//
//  Created by Branden Smith on 1/30/19.
//

import Foundation
import Network

extension API {
    enum WebView {
        static func getEnabledExtensions() -> Endpoint<WebViewExtensionsResponse> {
            return Endpoint<WebViewExtensionsResponse>(path: "v3/extensions/assets", parameters: ["enabled": true])
        }
    }
}
