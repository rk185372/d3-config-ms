//
//  SetupStep.swift
//  Session
//
//  Created by Branden Smith on 12/3/18.
//

import Foundation

public enum SetupStep: String, Codable {
    case securityQuestion = "setup.security-questions.required"
    case verifyEmail = "setup.primary-email-verification.required"
}
