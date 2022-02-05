//
//  SecurityQuestion.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/4/18.
//

import Foundation

public final class SecurityQuestion {
    let choices: [String]
    var value: String
    var response: String?

    init(choices: [String]) {
        self.choices = choices
        value = choices.randomElement() ?? ""
    }
}

extension SecurityQuestion {
    func dictionary() -> [String: Any?] {
        return [
            "question": value,
            "answer": response
        ]
    }
}

extension SecurityQuestion: Equatable {
    public static func ==(_ lhs: SecurityQuestion, _ rhs: SecurityQuestion) -> Bool {
        return lhs.choices == rhs.choices
            && lhs.value == rhs.value
            && lhs.response == rhs.response
    }
}
