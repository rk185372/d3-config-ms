//
//  EnablementConfigurationServices.swift
//  Enablement
//
//  Created by Chris Carranza on 8/15/18.
//

import Foundation
import LegalContent
import DeviceInfoService
import RxSwift
import Biometrics

public final class EnablementConfigurationServices {
    
    private let enablementService: EnablementService
    private let legalContentService: LegalContentService
    private let deviceInfoService: DeviceInfoService
    private let biometricsHelper: BiometricsHelper
    
    public init(enablementService: EnablementService,
                legalContentService: LegalContentService,
                deviceInfoService: DeviceInfoService,
                biometricsHelper: BiometricsHelper) {
        self.enablementService = enablementService
        self.legalContentService = legalContentService
        self.deviceInfoService = deviceInfoService
        self.biometricsHelper = biometricsHelper
    }
    
    func enableBiometrics() -> Completable {
        return biometricsHelper.optInBiometricAuth()
    }
    
    func enableSnapshot() -> Single<EnableResponse> {
        return deviceInfoService.getDeviceInfo().flatMap { deviceInfoResponse in
            self.enablementService.enableSnapshot(deviceId: deviceInfoResponse.id)
        }
    }
    
    func retrieveDisclosureText(legalServiceType: LegalServiceType) -> Single<String> {
        return legalContentService.retrieveDisclosure(legalServiceType: legalServiceType).map { $0.content }
    }
}
