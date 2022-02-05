//
//  DeviceDescriptionChallengeNetworkInterceptor.swift
//  DeviceDescriptionChallengeNetworkInterceptor
//
//  Created by David McRae on 8/28/19.
//

import Foundation
import AuthChallengeNetworkInterceptorApi
import RxSwift
import CompanyAttributes
import Utilities

final class DeviceDescriptionChallengeNetworkInterceptor: ChallengeNetworkInterceptor {

    private let companyAttributes: CompanyAttributesHolder
    private let device: Device
    
    init(companyAttributes: CompanyAttributesHolder, device: Device) {
        self.companyAttributes = companyAttributes
        self.device = device
    }
    
    func headers(for challengeType: String?) -> Single<[String: String]?> {
        return Single<[String: String]?>.create { observer in
            observer(.success(["d3-device-description": self.device.description]))
            
            return Disposables.create()
        }
    }
}
