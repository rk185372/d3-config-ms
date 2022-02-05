//
//  API+SecurityQuestions.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/4/18.
//

import Foundation
import Network
import Utilities

public extension API {
    enum SecurityQuestions {
        public static func getSecurityQuestions() -> Endpoint<[[String]]> {
            return Endpoint(method: .get, path: "v3/users/setup/security-questions")
        }

        public static func postSecurityQuestions(questions: Data) -> Endpoint<Void> {
            return Endpoint(method: .post, path: "v3/users/setup/security-questions", parameters: questions)
        }
    }
}
