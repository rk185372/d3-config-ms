//
//  NoneAkamaiChallengeNetworkInterceptor.swift
//  AkamaiChallengeNetworkInterceptor
//
//  Created by Branden Smith on 8/23/19.
//

import AuthChallengeNetworkInterceptorApi
import Foundation
import RxSwift

final class NoneAkamaiChallengeNetworkInterceptor: ChallengeNetworkInterceptor {

    init() {}

    func headers(for challengeType: String?) -> Single<[String: String]?> {
        return Single.just(nil)
    }
}
