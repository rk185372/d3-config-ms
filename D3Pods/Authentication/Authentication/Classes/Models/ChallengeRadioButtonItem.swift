//
//  ChallengeRadioButtonItem.swift
//  Authentication
//
//  Created by Chris Carranza on 7/10/18.
//

import Foundation
import Wrap
import RxSwift
import RxRelay

final class ChallengeRadioButtonItem: ChallengeItem, Decodable {
    let identifier: String
    let challengeName: String
    let tabIndex: Int?
    let items: [RadioItem]
    var selectedItem: RadioItem? {
        return items.first(where: { $0.selected })
    }
    
    enum CodingKeys: CodingKey {
        case identifier
        case challengeName
        case tabIndex
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        challengeName = try container.decode(String.self, forKey: .challengeName)
        tabIndex = try container.decodeIfPresent(Int.self, forKey: .tabIndex)
        items = try container.decode([RadioItem].self, forKey: .items)

        items.first(where: { !$0.disabled })?.selected = true
    }

    func validate(type: ValidationType) -> ValidationStatus {
        for item in items {
            let status = item.validate(type: type)
            guard case ValidationStatus.error = status else { continue }
            return status
        }
        
        return .noErrors
    }
}

extension ChallengeRadioButtonItem: WrapCustomizable {
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        var wrappedDictionary: WrappedDictionary = [
            "identifier": identifier,
            "value": selectedItem?.value as Any
        ]
        
        if let response = selectedItem?.inputValue {
            wrappedDictionary["response"] = response
        }
        
        return wrappedDictionary
    }
}

extension ChallengeRadioButtonItem: Equatable {
    static func ==(lhs: ChallengeRadioButtonItem, rhs: ChallengeRadioButtonItem) -> Bool {
        guard lhs.identifier == rhs.identifier else { return false }
        guard lhs.challengeName == rhs.challengeName else { return false }
        guard lhs.items == rhs.items else { return false }
        guard lhs.selectedItem == rhs.selectedItem else { return false }
        
        return true
    }
}

extension ChallengeRadioButtonItem {
    final class RadioItem: Decodable, Equatable, Validatable {
        let title: String
        let description: String?
        let value: String
        let disabled: Bool
        let input: Input?
        var selected: Bool = false
        var inputValue: String? {
            get {
                return input?.value
            }
            set {
                input?.value = newValue
            }
        }
        
        enum CodingKeys: CodingKey {
            case title
            case description
            case value
            case disabled
            case input
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            description = try? container.decode(String.self, forKey: .description)
            value = try container.decode(String.self, forKey: .value)
            disabled = try container.decodeIfPresent(Bool.self, forKey: .disabled) ?? false
            input = try container.decodeIfPresent(Input.self, forKey: .input)
        }
        
        static func == (lhs: ChallengeRadioButtonItem.RadioItem, rhs: ChallengeRadioButtonItem.RadioItem) -> Bool {
            guard lhs.title == rhs.title else { return false }
            guard lhs.description == rhs.description else { return false }
            guard lhs.value == rhs.value else { return false }
            guard lhs.disabled == rhs.disabled else { return false }
            guard lhs.selected == rhs.selected else { return false }
            guard lhs.input == rhs.input else { return false }
            
            return true
        }
        
        func validate(type: ValidationType) -> ValidationStatus {
            guard selected else { return .noErrors }
            return (input != nil) ? input!.validate(type: type) : .noErrors
        }
    }
}

extension ChallengeRadioButtonItem.RadioItem {
    final class Input: Decodable, Equatable, Validatable {
        let title: String
        let placeholder: String
        let description: String?
        let lengthValidator: LengthValidator?
        let regexValidator: RegexValidator?
        fileprivate var _errors = BehaviorRelay<[String]>(value: [])
        var errors: [String] {
            get { return _errors.value }
            set { _errors.accept(newValue) }
        }
        var value: String?
        
        enum CodingKeys: CodingKey {
            case title
            case placeholder
            case description
            case validators
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            placeholder = try container.decode(String.self, forKey: .placeholder)
            description = try? container.decode(String.self, forKey: .description)
            
            if let validator = try container.decodeIfPresent(ValidatorRaw.self, forKey: .validators) {
                let factory = ValidatorFactory(validator: validator)
                lengthValidator = factory.createLengthValidator()
                regexValidator = factory.createRegexValidator()
            } else {
                lengthValidator = nil
                regexValidator = nil
            }
        }
        
        static func == (lhs: ChallengeRadioButtonItem.RadioItem.Input, rhs: ChallengeRadioButtonItem.RadioItem.Input) -> Bool {
            guard lhs.title == rhs.title else { return false }
            guard lhs.placeholder == rhs.placeholder else { return false }
            
            return true
        }
        
        func validate(type: ValidationType) -> ValidationStatus {
            errors.removeAll()
            
            let lengthClosure = {
                if let error = self.lengthValidator?.validate(text: self.value ?? "") {
                    self.errors.append(error)
                }
            }
            
            let regexClosure = {
                if let value = self.value, let error = self.regexValidator?.validate(text: value) {
                    self.errors.append(error)
                }
            }
            
            switch type {
            case .form:
                lengthClosure()
                regexClosure()
            case .focusChange:
                lengthClosure()
            }
            
            return !errors.isEmpty ? .error(message: errors.first!) : .noErrors
        }
    }
}

extension ChallengeRadioButtonItem.RadioItem.Input: ReactiveCompatible {}

extension Reactive where Base: ChallengeRadioButtonItem.RadioItem.Input {
    var errors: Observable<[String]> {
        return base._errors.asObservable()
    }
}
