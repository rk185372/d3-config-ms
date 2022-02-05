//
//  WKHTTPCookieStore+.swift
//  Web
//
//  Created by Andrew Watt on 7/20/18.
//

import Foundation
import WebKit

extension WKHTTPCookieStore {
    /// Set multiple cookies, with a single completion handler.
    /// - parameters:
    ///   - cookies: The cookies to set.
    ///   - completion: A completion block to be called when all cookies have been set. The block
    ///                 will be called on the main queue.
    public func set(cookies: [HTTPCookie], completion: @escaping () -> Void) {
        let completionDispatchGroup = DispatchGroup()

        for cookie in cookies {
            completionDispatchGroup.enter()
            setCookie(cookie) {
                completionDispatchGroup.leave()
            }
        }
        
        completionDispatchGroup.notify(queue: .main, execute: completion)
    }
}
