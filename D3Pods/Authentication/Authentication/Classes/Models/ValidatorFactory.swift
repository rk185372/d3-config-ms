//
//  ValidatorFactory.swift
//  Authentication
//
//  Created by Branden Smith on 8/22/18.
//

import Foundation

final class ValidatorFactory {
    private let validator: ValidatorRaw
    
    init(validator: ValidatorRaw) {
        self.validator = validator
    }
    
    func createLengthValidator() -> LengthValidator? {
        guard let raw = validator.length else { return nil }
        return LengthValidator(raw: raw)
    }
    
    func createConfirmationValidator() -> ConfirmationValidator? {
        guard let raw = validator.confirmation else { return nil }
        return ConfirmationValidator(raw: raw)
    }
    
    func createRegexValidator() -> RegexValidator? {
        guard let raw = validator.regex else { return nil }
        return RegexValidator(raw: raw)
    }
}
