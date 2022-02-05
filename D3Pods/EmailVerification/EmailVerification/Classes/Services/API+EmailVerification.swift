//
//  API+EmailVerifications.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/6/21.
//

import Foundation
import Network
import Utilities

public extension API {
    enum EmailVerification {
        public static func postPrimaryEmail(email: Data) -> Endpoint<Void> {
            return Endpoint(method: .post, path: "v4/profiles/set-primary-email", parameters: email)
        }
        
        public static func cleanEmailVerify() -> Endpoint<Void> {
            return Endpoint(method: .delete, path: "v4/users/current/clear-email-verify")
        }
    }
}
