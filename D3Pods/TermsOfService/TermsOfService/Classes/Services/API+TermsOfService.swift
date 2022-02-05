//
//  API+TermsOfService.swift
//  TermsOfService
//
//  Created by Chris Carranza on 4/5/18.
//

import Foundation
import Network

extension API {
    enum TermsOfService {
        static func accept(service: String, parameters: Parameters) -> Endpoint<Void> {
            return Endpoint<Void>(method: .post, path: "v3/users/current/enrollment/tos/acceptance/\(service)", parameters: parameters)
        }
    }
}
