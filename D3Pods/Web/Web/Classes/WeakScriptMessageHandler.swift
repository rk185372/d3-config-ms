//
//  WeakScriptMessageHandler.swift
//  Web
//
//  Created by Andrew Watt on 8/17/18.
//

import Foundation
import WebKit

/// Wraps a `WKScriptMessageHandler` with a weak reference to avoid a retain cycle.
final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    private weak var handler: WKScriptMessageHandler?
    
    init(around handler: WKScriptMessageHandler) {
        self.handler = handler
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handler?.userContentController(userContentController, didReceive: message)
    }
}
