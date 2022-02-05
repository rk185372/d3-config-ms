//
//  EnablementNetworkInterceptor.swift
//  EnablementNetworkInterceptorApi
//
//  Created by David McRae on 8/27/19.
//

import Foundation
import RxSwift

public protocol EnablementNetworkInterceptor {
    func headers() -> Single<[String: String]?>
}

public final class EnablementNetworkInterceptorItem {
    private var interceptors: [EnablementNetworkInterceptor]

    public init(interceptors: [EnablementNetworkInterceptor] = []) {
        self.interceptors = interceptors
    }

    public func headers() -> Single<[String: String]?> {
        let singles = interceptors.map({ return $0.headers().asObservable() })
        
        return Observable
            .zip(singles)
            .map({ results in
                var headers: [String: String] = [:]

                results.compactMap({ $0 }).forEach { dict in
                    dict.forEach { (key, value) in
                        headers[key] = value
                    }
                }

                return headers
            })
            .asSingle()
    }

    public func register(interceptor: EnablementNetworkInterceptor) {
        interceptors.append(interceptor)
    }
}
