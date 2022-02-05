//
//  WebViewExtensionsCache.swift
//  Web
//
//  Created by Branden Smith on 1/30/19.
//

import Foundation
import Logging
import RxSwift

public final class WebViewExtensionsCache {

    private let serviceItem: WebViewService
    private let bag: DisposeBag = DisposeBag()
    private var extensionsSuccessfullyRetrieved = false
    private var localExtensions: WebViewExtensionsResponse!
    private var enabledExtensions: WebViewExtensionsResponse!

    init(serviceItem: WebViewService, localExtensionsFilename: String, bundle: Bundle) {
        self.serviceItem = serviceItem
        self.localExtensions = loadLocalExtensions(filename: localExtensionsFilename, bundle: bundle)
    }

    /// Gets the enabled extensions that have been pre-built with the app and are enabled
    /// on the server. If the network call to fetch the extensions from the server fails,
    /// this method returns all of the extensions built with the app. If the network request
    /// succeeds, this method returns only the extensions that were pre-built with the app and
    /// are listed as enabled on the server.
    ///
    /// Note: This method has been marked @objc public dynamic so that it is swizzleable from
    /// the build info screen. Changing this will break that swizzling in debug mode.
    /// - Parameters:
    ///   - completion: Success handler called with valid extensions.
    @objc public dynamic func getEnabledExtensions(completion: @escaping (WebViewExtensionsResponse) -> Void) {
        guard !extensionsSuccessfullyRetrieved else {
            completion(enabledExtensions)

            return
        }
        
        serviceItem
            .getEnabledExtensions()
            .subscribe(onSuccess: { response in
                self.extensionsSuccessfullyRetrieved = true

                let extensions = self.merge(
                    localExtensions: self.localExtensions.extensions,
                    newExtensions: response.extensions
                )

                self.enabledExtensions = WebViewExtensionsResponse(extensions: extensions, fonts: response.fonts)
                completion(self.enabledExtensions)
            }, onError: { error in
                log.warning("Failed to get extensions", context: error)
                self.enabledExtensions = self.localExtensions

                completion(self.enabledExtensions)
            })
            .disposed(by: bag)

    }

    private func merge(localExtensions: [WebViewExtension], newExtensions: [WebViewExtension]) -> [WebViewExtension] {
        var extensions = [WebViewExtension]()
        let newExtensionsDict = newExtensions.reduce(into: [:], { (result, newExtension) in
            result[newExtension.sourceAssetId] = newExtension
        })

        for `extension` in localExtensions {
            if let ext = newExtensionsDict[`extension`.sourceAssetId], !ext.disabled {
                extensions.append(`extension`)
            }
        }

        return extensions
    }

    private func loadLocalExtensions(filename: String, bundle: Bundle) -> WebViewExtensionsResponse {
        if
            let url = bundle.url(forResource: filename, withExtension: "json"),
            let data = try? Data(contentsOf: url, options: .mappedIfSafe),
            let response = try? JSONDecoder().decode(WebViewExtensionsResponse.self, from: data)
        {
            return response
        }

        return WebViewExtensionsResponse(extensions: [], fonts: [])
    }
}
