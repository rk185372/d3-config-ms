//
//  Validator.swift
//  Authentication
//
//  Created by Branden Smith on 8/21/18.
//

import Foundation

protocol Validatable {
    @discardableResult
    func validate(type: ValidationType) -> ValidationStatus
}

enum ValidationType {
    case focusChange
    case form(items: [ChallengeItem])
}

enum ValidationStatus {
    case noErrors
    case error(message: String)
}

struct LengthValidator {
    private let min: Int
    private let max: Int
    private let message: String
    
    init(raw: LengthValidatorRaw) {
        min = raw.min
        max = raw.max
        message = raw.message
    }
    
    func validate(text: String) -> String? {
        return (text.count < min || text.count > max) ? message : nil
    }
}

struct ConfirmationValidator {
    private let identifier: String
    private let message: String
    
    init(raw: ConfirmationValidatorRaw) {
        identifier = raw.identifier
        message = raw.message
    }
    
    func matchesIdentifier(identifier: String) -> Bool {
        return self.identifier == identifier
    }
    
    func validate(lhsValue: String, rhsValue: String) -> String? {
        return (lhsValue != rhsValue) ? message : nil
    }
}

struct RegexValidator {
    private let expression: String
    private let message: String
    
    init(raw: RegexValidatorRaw) {
        expression = raw.expression
        message = raw.message
    }
    
    func validate(text: String) -> String? {
        return (text.range(of: expression, options: .regularExpression) == nil) ? message : nil
    }
}

struct ValidatorRaw: Decodable {
    let length: LengthValidatorRaw?
    let confirmation: ConfirmationValidatorRaw?
    let regex: RegexValidatorRaw?
}

struct LengthValidatorRaw: Decodable {
    let min: Int
    let max: Int
    let message: String
}

struct ConfirmationValidatorRaw: Decodable {
    let identifier: String
    let message: String
}

struct RegexValidatorRaw: Decodable {
    let expression: String
    let message: String
}
