//
//  WebViewExtensionsCache+Swizzle.swift
//  Accounts-iOS
//
//  Created by Branden Smith on 3/30/20.
//

import Foundation
import Logging
import RxSwift
import Web

extension WebViewExtensionsCache {
    @objc dynamic func swizzledGetEnabledExtensions(completion: @escaping (WebViewExtensionsResponse) -> Void) {
        guard let container = BuildInfoScreenModule.currentDependencyContainer else {
            fatalError("There is no current dependency container in the BuildInfoScreenModule")
        }

        let serviceItem: WebViewService = try! container.resolve()

        _ = serviceItem
            .getEnabledExtensions()
            .subscribe(onSuccess: { response in
                completion(response)
            }, onError: { error in
                log.warning("Failed to get extensions in swizzled getEnabledExtensions", context: error)
                completion(WebViewExtensionsResponse(extensions: [], fonts: []))
            })
    }

    static func swizzleGetEnabledExtensions() {
        let original = class_getInstanceMethod(
            WebViewExtensionsCache.self,
            #selector(getEnabledExtensions(completion:))
        )
        let swizzled = class_getInstanceMethod(
            WebViewExtensionsCache.self,
            #selector(swizzledGetEnabledExtensions(completion:))
        )

        method_exchangeImplementations(original!, swizzled!)
    }
}
