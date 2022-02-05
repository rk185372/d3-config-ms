//
//  WebViewService.swift
//  Web
//
//  Created by Branden Smith on 1/30/19.
//

import Foundation
import RxSwift
import Network

public protocol WebViewService {
    func getEnabledExtensions() -> Single<WebViewExtensionsResponse>
}

public final class WebViewServiceItem: WebViewService {
    let client: ClientProtocol

    public init(client: ClientProtocol) {
        self.client = client
    }

    public func getEnabledExtensions() -> Single<WebViewExtensionsResponse> {
        return client.request(API.WebView.getEnabledExtensions())
    }
}
