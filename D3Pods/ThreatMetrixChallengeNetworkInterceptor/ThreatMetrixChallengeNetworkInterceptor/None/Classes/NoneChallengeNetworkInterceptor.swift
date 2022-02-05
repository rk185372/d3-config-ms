//
//  NoneChallengeNetworkInterceptor.swift
//  AuthChallengeNetworkInterceptor
//
//  Created by Chris Carranza on 5/6/19.
//

import Foundation
import AuthChallengeNetworkInterceptorApi
import RxSwift

final class NoneThreatMetrixChallengeNetworkInterceptor: ChallengeNetworkInterceptor {
    init() {}
    
    func headers(for challengeType: String?) -> Single<[String: String]?> {
        return Single.just(nil)
    }
}
