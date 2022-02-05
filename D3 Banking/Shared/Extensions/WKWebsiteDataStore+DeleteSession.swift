//
//  WKWebsiteDataStore+DeleteSession.swift
//  D3 Banking
//
//  Created by David McRae Jr on 2/27/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation
import WebKit
import Logging

extension WKWebsiteDataStore {
    
    public func deleteSessionCookie() {
        // Remove the session cookie from the WKWebView so when we login again we don't have duplicates
        httpCookieStore.getAllCookies({ cookies in
            cookies.filter({ $0.name == "SESSION" }).forEach { cookie in
                self.httpCookieStore.delete(cookie, completionHandler: {
                    log.debug("Session cookie deleted")
                })
            }
        })
    }
}
