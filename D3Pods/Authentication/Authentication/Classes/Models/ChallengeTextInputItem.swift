//
//  ChallengeTextInputItem.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/5/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import Utilities
import Wrap

final class ChallengeTextInputItem: TextInputChallengeItem, Decodable {
    let identifier: String
    let challengeName: String
    let title: String?
    let placeholder: String?
    let tabIndex: Int?
    let displayText: String?
    let isSecure: Bool
    let isEditable: Bool
    let lengthValidator: LengthValidator?
    let confirmationValidator: ConfirmationValidator?
    var value: String?
    var maskedValue: String?
    let button: Button?
    var errors: [String] = []

    enum CodingKeys: String, CodingKey {
        case identifier
        case challengeName
        case title
        case placeholder
        case tabIndex
        case isSecure
        case isEditable
        case displayText
        case validators
        case button
    }
    
    init(identifier: String,
         challengeName: String,
         title: String?,
         placeholder: String?,
         tabIndex: Int?,
         isSecure: Bool,
         isEditable: Bool,
         displayText: String,
         lengthValidator: LengthValidator?,
         confirmationValidator: ConfirmationValidator?,
         value: String? = nil,
         maskedValue: String? = nil,
         button: Button? = nil) {
        self.identifier = identifier
        self.challengeName = challengeName
        self.title = title
        self.placeholder = placeholder
        self.tabIndex = tabIndex
        self.isSecure = isSecure
        self.isEditable = isEditable
        self.displayText = displayText
        self.lengthValidator = lengthValidator
        self.confirmationValidator = confirmationValidator
        self.value = value
        self.maskedValue = maskedValue
        self.button = button
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decode(String.self, forKey: .identifier)
        challengeName = try container.decode(String.self, forKey: .challengeName)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        tabIndex = try container.decodeIfPresent(Int.self, forKey: .tabIndex)
        displayText = try container.decodeIfPresent(String.self, forKey: .displayText)
        isSecure = try container.decode(Bool.self, forKey: .isSecure)
        isEditable = (try? container.decode(Bool.self, forKey: .isEditable)) ?? true
        button = try container.decodeIfPresent(Button.self, forKey: .button)

        if let validator = try container.decodeIfPresent(ValidatorRaw.self, forKey: .validators) {
            let factory = ValidatorFactory(validator: validator)
            lengthValidator = factory.createLengthValidator()
            confirmationValidator = factory.createConfirmationValidator()
        } else {
            lengthValidator = nil
            confirmationValidator = nil
        }
    }

    func validate(type: ValidationType) -> ValidationStatus {
        errors.removeAll()
        
        let lengthClosure = {
            if let error = self.lengthValidator?.validate(text: self.value ?? "") {
                self.errors.append(error)
            }
        }
        
        let confirmationClosure = { (allItems: [ChallengeItem]) in
            guard let value = self.value else { return }
            guard let validator = self.confirmationValidator else { return }
            guard let matchingItem = allItems
                .first(where: { validator.matchesIdentifier(identifier: $0.identifier) }) as? TextInputChallengeItem,
                let matchingInput = matchingItem.value else { return }
            
            if let error = validator.validate(lhsValue: matchingInput, rhsValue: value) {
                self.errors.append(error)
            }
        }
        
        switch type {
        case .form(let items):
            lengthClosure()
            confirmationClosure(items)
        case .focusChange:
            lengthClosure()
        }

        return !errors.isEmpty ? .error(message: errors.first!) : .noErrors
    }
}

extension ChallengeTextInputItem: WrapCustomizable {
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        let wrappedDictionary: WrappedDictionary = [
            "identifier": identifier,
            "value": value as Any
        ]
        
        return wrappedDictionary
    }
}

extension ChallengeTextInputItem: Equatable {
    static func ==(lhs: ChallengeTextInputItem, rhs: ChallengeTextInputItem) -> Bool {
        guard lhs.identifier == rhs.identifier else { return false }
        guard lhs.challengeName == rhs.challengeName else { return false }
        guard lhs.placeholder == rhs.placeholder else { return false }
        guard lhs.displayText == rhs.displayText else { return false }
        guard lhs.isSecure == rhs.isSecure else { return false }
        guard lhs.isEditable == rhs.isEditable else { return false }
        guard lhs.value == rhs.value else { return false }
        
        return true
    }
}

extension ChallengeTextInputItem {
    final class Button: Decodable {
        var title: String?
        var iconType: String?
        var url: URL?
        var buttonDialog: ChallengeButtonDialog?
        
        enum CodingKeys: String, CodingKey {
            case title
            case iconType
            case url
            case buttonDialog
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try? container.decodeIfPresent(String.self, forKey: .title) ?? nil
            iconType = try? container.decodeIfPresent(String.self, forKey: .iconType) ?? nil
            url = try? container.decodeIfPresent(URL.self, forKey: .url) ?? nil
            buttonDialog = try? container.decodeIfPresent(ChallengeButtonDialog.self, forKey: .buttonDialog) ?? nil
        }
    }
}
