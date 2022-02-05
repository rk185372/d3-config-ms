//
//  WebClient+Swizzle.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 11/1/19.
//

import Foundation
import Web

extension WebClient {
    @objc dynamic var swizzledNavigationURL: URL {
        guard let baseUrl = Bundle.main.url(forResource: "webComponents", withExtension: nil) else {
            fatalError("webComponents missing")
        }

        return URL(string: "\(baseUrl)index.html?translate=false#\(componentPath.path)")!
    }

    static func swizzleNavigationURL() {
        let original = class_getInstanceMethod(WebClient.self, #selector(getter: navigationURL))
        let swizzled = class_getInstanceMethod(WebClient.self, #selector(getter: swizzledNavigationURL))

        method_exchangeImplementations(original!, swizzled!)
    }
}
