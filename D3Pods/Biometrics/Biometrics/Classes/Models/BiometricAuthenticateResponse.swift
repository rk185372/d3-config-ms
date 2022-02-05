//
//  BiometricAuthenticateResponse.swift
//  Biometrics
//
//  Created by Chris Carranza on 8/17/18.
//

import Foundation

public struct BiometricAuthenticateResponse: Codable, Equatable {
    public var biometricToken: String
}
