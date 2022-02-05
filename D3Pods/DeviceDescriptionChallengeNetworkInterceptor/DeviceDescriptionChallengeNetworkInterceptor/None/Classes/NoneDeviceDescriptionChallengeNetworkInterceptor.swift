//
//  NoneDeviceDescriptionChallengeNetworkInterceptor.swift
//  NoneDeviceDescriptionChallengeNetworkInterceptor
//
//  Created by David McRae on 8/28/19.
//

import Foundation
import AuthChallengeNetworkInterceptorApi
import RxSwift

final class NoneDeviceDescriptionChallengeNetworkInterceptor: ChallengeNetworkInterceptor {
    init() {}
    
    func headers(for challengeType: String?) -> Single<[String: String]?> {
        return Single.just(nil)
    }
}
