//
//  AkamaiChallengeNetworkInterceptor.swift
//  Akamai
//
//  Created by Branden Smith on 8/13/19.
//

import Akamai
import AuthChallengeNetworkInterceptorApi
import Foundation
import RxSwift

final class AkamaiChallengeNetworkInterceptor: ChallengeNetworkInterceptor {

    init() {}

    func headers(for challengeType: String?) -> Single<[String: String]?> {
        return Single<[String: String]?>.create { observer in
            let sensorData: String = CYFMonitor.getSensorData()

            observer(
                .success([
                    "X-acf-sensor-data": sensorData,
                    "d3-challenge-type": challengeType ?? ""
                ])
            )

            return Disposables.create()
        }
    }
}
