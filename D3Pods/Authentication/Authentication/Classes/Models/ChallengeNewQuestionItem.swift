//
//  ChallengeNewQuestionItem.swift
//  Authentication
//
//  Created by Branden Smith on 7/20/18.
//

import Foundation
import Wrap

final class ChallengeNewQuestionItem: TextInputChallengeItem, Decodable {

    enum CodingKeys: CodingKey {
        case identifier
        case challengeName
        case questions
        case placeholder
        case validators
        case tabIndex
    }

    let identifier: String
    let challengeName: String
    let tabIndex: Int?
    let questions: [String]
    let placeholder: String
    let lengthValidator: LengthValidator?
    var errors: [String] = []

    var selectedQuestion: String?
    var value: String?

    init(identifier: String, challengeName: String, questions: [String], placeholder: String, lengthValidator: LengthValidator? = nil) {
        self.identifier = identifier
        self.challengeName = challengeName
        self.questions = questions
        self.placeholder = placeholder
        self.lengthValidator = lengthValidator
        selectedQuestion = questions.first
        value = ""
        self.tabIndex = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        challengeName = try container.decode(String.self, forKey: .challengeName)
        questions = try container.decode([String].self, forKey: .questions)
        placeholder = try container.decode(String.self, forKey: .placeholder)
        tabIndex = try container.decodeIfPresent(Int.self, forKey: .tabIndex)
        
        if let validator = try container.decodeIfPresent(ValidatorRaw.self, forKey: .validators) {
            let factory = ValidatorFactory(validator: validator)
            lengthValidator = factory.createLengthValidator()
        } else {
            lengthValidator = nil
        }

        selectedQuestion = questions.first
        value = ""
    }

    func validate(type: ValidationType) -> ValidationStatus {
        errors.removeAll()
        
        if let value = self.value, let error = self.lengthValidator?.validate(text: value) {
            self.errors.append(error)
        }
        
        return !errors.isEmpty ? .error(message: errors.first!) : .noErrors
    }
}

extension ChallengeNewQuestionItem: Equatable {
    static func ==(_ lhs: ChallengeNewQuestionItem, _ rhs: ChallengeNewQuestionItem) -> Bool {
        guard lhs.identifier == rhs.identifier else { return false }
        guard lhs.challengeName == rhs.challengeName else { return false }
        guard lhs.questions == rhs.questions else { return false }
        guard lhs.placeholder == rhs.placeholder else { return false }
        
        return true
    }
}

extension ChallengeNewQuestionItem: WrapCustomizable {
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        let wrappedDictionary: WrappedDictionary = [
            "identifier": identifier,
            "question": selectedQuestion!,
            "value": value as Any
        ]

        return wrappedDictionary
    }
}
