//
//  Client+RestServer.swift
//  Pods
//
//  Created by Chris Carranza on 2/21/18.
//

import Alamofire
import AppConfiguration
import Foundation
import Utilities

public extension Client {
    convenience init(restServer: RestServer, requestAdapter: RequestAdapter? = nil, requestTransformer: RequestTransformer? = nil) {
        let trustPackages = restServer.sslCertificates.map {
            ServerTrustPackage(
                domain: restServer.url.host!,
                hashes: $0.hashSet,
                hashingAlgorithms: $0.algorithmIntegers
            )
        }
        
        if trustPackages.isEmpty {
            self.init(domain: restServer.url, requestAdapter: requestAdapter, requestTransformer: requestTransformer)
        } else {
            let trustPolicyManager = D3TrustPolicyManager(serverTrustPackages: trustPackages)
            self.init(
                domain: restServer.url,
                requestAdapter: requestAdapter,
                trustPolicyManager: trustPolicyManager,
                requestTransformer: requestTransformer
            )
        }
    }
}
