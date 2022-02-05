//
//  API+Biometrics.swift
//  BiometricsHelper
//
//  Created by Chris Carranza on 8/16/18.
//

import Foundation
import Network

extension API {
    enum Biometrics {
        
        static func optInBiometricAuth(deviceId: Int, headers: [String: String]?) -> Endpoint<EnableResponse> {
            return Endpoint(method: .post, path: "v3/devices/\(deviceId)/opt-in-biometric-auth", headers: headers)
        }
        
        static func optOutBiometricAuth(deviceId: Int, headers: [String: String]? = nil) -> Endpoint<DisableResponse> {
            return Endpoint<DisableResponse>(
                method: .post,
                path: "v3/devices/\(deviceId)/opt-out-biometric-auth",
                headers: headers
            )
        }
        
        static func authenticate(uuid: String, token: String, headers: [String: String]?) -> Endpoint<BiometricAuthenticateResponse> {
            return Endpoint(method: .post, path: "v3/devices/\(uuid)/authenticate-token", headers: headers, parameters: ["token": token])
        }
    }
}
