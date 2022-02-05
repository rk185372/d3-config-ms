//
//  ShapeSecurityRequestTransformer.swift
//  RequestTransformer
//
//  Created by Branden Smith on 11/14/19.
//

import Alamofire
import APIGuard
import Foundation
import Logging
import RxSwift
import Utilities

public final class ShapeSecurityRequestTransformer: NSObject, RequestTransformer {

    private let shape: APIGuard

    public override init() {
        guard let apiGuard = APIGuard.sharedInstance() else {
            fatalError("API Guard Shared Instance could not be resolved")
        }

        guard let configPath = ShapeSecurityBundle.bundle.path(forResource: "APIGuardConfig_iOS", ofType: "json") else {
            fatalError("Missing config file for shape security.")
        }

        self.shape = apiGuard

        super.init()

        shape.initialize(withConfigFile: configPath, delegate: self)
    }

    public func transform(_ request: URLRequest) -> Single<URLRequest> {
        guard let url = request.url?.absoluteString else { return Single.just(request) }

        var transformedRequest = request

        // We get all of the headers on the DataRequest's URLRequest
        var headers: [String: String] = request.allHTTPHeaderFields ?? [:]

        // Get any additional headers from the RequestTransformer
        if let additionalHeaders = shape.getRequestHeaders(url, body: request.httpBody) {
            headers += additionalHeaders
        }

        // Given the union of the original headers and the additional headers,
        // we iterate over each entry in this union and set the header on the copied
        // URLRequest
        headers.forEach { entry in
            transformedRequest.setValue(entry.value, forHTTPHeaderField: entry.key)
        }

        return Single.just(transformedRequest)
    }

    public func process(_ response: HTTPURLResponse?) {
        guard let response = response else { return }

        shape.parseResponse(response)
    }
}

extension ShapeSecurityRequestTransformer: APIGuardDelegate {
    public func checkCertificates(_ challenge: URLAuthenticationChallenge) -> Bool {
        return true
    }

    public func log(_ string: String) {
        Logging.log.debug(string)
    }
}
