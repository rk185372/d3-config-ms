//
//  QuestionResponseValidator.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/6/21.
//

import Foundation

protocol EmailValidator {
    func validate(_ input: String?) -> ValidationResponse
}

enum ValidationResponse {
    case valid
    case invalid(message: String)
}

struct EmailRegexValidator: EmailValidator {
    private let pattern: String = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
    private let errorMessage: String
    private let emptyErrorMessage: String
    
    init(errorMessage: String, emptyErrorMessage: String) {
        self.errorMessage = errorMessage
        self.emptyErrorMessage = emptyErrorMessage
    }

    func validate(_ input: String?) -> ValidationResponse {
        guard let input = input, !input.isEmpty else {
            return .invalid(message: emptyErrorMessage)
        }
        
        guard input.range(of: pattern, options: .regularExpression) != nil else {
            return .invalid(message: errorMessage)
        }
        
        return .valid
    }
}

@objc public protocol EmailInput {
    var email: String? { get }
}

struct EmailMatchingValidator: EmailValidator {
    private let otherInput: EmailInput
    private let notMatchingErrorMessage: String
    
    init(otherInput: EmailInput, notMatchingErrorMessage: String) {
        self.otherInput = otherInput
        self.notMatchingErrorMessage = notMatchingErrorMessage
    }
    
    func validate(_ input: String?) -> ValidationResponse {
        if input != otherInput.email {
            return .invalid(message: notMatchingErrorMessage)
        }

        return .valid
    }
}
