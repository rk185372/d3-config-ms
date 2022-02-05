//
//  ChallengeItem.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/5/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation

public enum ChallengeName: String, Codable {
    case tabSegment
    case username
    case business_tooltip
    case business_username
    case password
    case business_password
    case newPassword
    case confirmPassword
    case secretQuestion
    case rememberDevice
    case saveUsername
    case saveBusinessUsername
    case mfaMethodSelection
    case mfaPhoneNumberSelection
    case newMFAOOBChallenge
    case newMFANewQuestion
}

protocol ChallengeItem: Decodable, Validatable {
    var identifier: String { get }
    var challengeName: String { get }
    var tabIndex: Int? { get }
}

protocol TextInputChallengeItem: ChallengeItem {
    var value: String? { get }
}
