//
//  BiometricsService.swift
//  Biometrics
//
//  Created by Chris Carranza on 8/16/18.
//

import EnablementNetworkInterceptorApi
import Foundation
import Network
import Utilities
import RxSwift

public final class BiometricsService {
    
    private let client: ClientProtocol
    private let uuid: D3UUID
    private let networkInterceptor: EnablementNetworkInterceptorItem
    
    init(client: ClientProtocol, uuid: D3UUID, networkInterceptor: EnablementNetworkInterceptorItem) {
        self.client = client
        self.uuid = uuid
        self.networkInterceptor = networkInterceptor
    }
    
    public func optInBiometricAuth(deviceId: Int) -> Single<EnableResponse> {
        return self.networkInterceptor
            .headers()
            .flatMap({ headers in
                self.client.request(API.Biometrics.optInBiometricAuth(deviceId: deviceId, headers: headers))
            })
    }
    
    public func optOutBiometricAuth(deviceId: Int) -> Single<DisableResponse> {
        return networkInterceptor
            .headers()
            .flatMap({ (headers) -> Single<DisableResponse> in
                self.client.request(API.Biometrics.optOutBiometricAuth(deviceId: deviceId, headers: headers))
            })
    }
    
    public func authenticate(token: String) -> Single<BiometricAuthenticateResponse> {
        return self.networkInterceptor
            .headers()
            .flatMap({ headers in
                self.client.request(API.Biometrics.authenticate(uuid: self.uuid.uuidString, token: token, headers: headers))
            })
    }
}
