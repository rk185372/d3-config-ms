//
//  MFAEnrollmentResponse.swift
//  Authentication
//
//  Created by Ignacio Mariani on 01/12/2021.
//

import Foundation

public struct MFAEnrollmentResponse: Codable {
    let content, format: String
    let usageType: String
}
