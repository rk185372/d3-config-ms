//
//  QuestionResponseValidator.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/7/18.
//

import Foundation

protocol QuestionResponseValidator {
    func validate(question: SecurityQuestion) -> QuestionValidationResponse
}

enum QuestionValidationResponse {
    case valid
    case invalid(message: String)
}

struct QuestionRegexValidator: QuestionResponseValidator {
    private let pattern: String
    private let errorMessage: String

    init(pattern: String, errorMessage: String) {
        self.pattern = pattern
        self.errorMessage = errorMessage
    }

    func validate(question: SecurityQuestion) -> QuestionValidationResponse {
        guard question.response?.range(of: pattern, options: .regularExpression) != nil else {
            return .invalid(message: errorMessage)
        }
        return .valid
    }
}

struct QuestionLengthValidator: QuestionResponseValidator {
    private let minLength: Int
    private let maxLength: Int
    private let emptyErrorMessage: String
    private let minLengthError: String
    private let maxLengthError: String

    init(minLength: Int, maxLength: Int, emptyErrorMessage: String, minLengthError: String, maxLengthError: String) {
        self.minLength = minLength
        self.maxLength = maxLength
        self.emptyErrorMessage = emptyErrorMessage
        self.minLengthError = minLengthError
        self.maxLengthError = maxLengthError
    }

    func validate(question: SecurityQuestion) -> QuestionValidationResponse {
        guard let response = question.response, !response.isEmpty else {
            return .invalid(message: emptyErrorMessage)
        }

        if response.count < minLength {
            return .invalid(message: minLengthError)
        } else if response.count > maxLength {
            return .invalid(message: maxLengthError)
        }

        return .valid
    }
}
