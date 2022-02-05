//
//  ChallengeNetworkInterceptor.swift
//  AuthChallengeNetworkInterceptorApi
//
//  Created by Chris Carranza on 5/6/19.
//

import Foundation
import RxSwift

public protocol ChallengeNetworkInterceptor {
    func headers(for challengeType: String?) -> Single<[String: String]?>
}

public final class ChallengeNetworkInterceptorItem {
    private var interceptors: [ChallengeNetworkInterceptor]

    public init(interceptors: [ChallengeNetworkInterceptor] = []) {
        self.interceptors = interceptors
    }

    public func headers(for challengeType: String?) -> Single<[String: String]?> {
        let singles = interceptors.map({ return $0.headers(for: challengeType).asObservable() })

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

    public func register(interceptor: ChallengeNetworkInterceptor) {
        interceptors.append(interceptor)
    }
}
