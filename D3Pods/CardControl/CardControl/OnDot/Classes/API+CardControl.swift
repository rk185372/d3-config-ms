//
//  API+CardControl.swift
//  CardControl
//
//  Created by Elvin Bearden on 3/2/21.
//

import Foundation
import Network
import Utilities

public extension API {
    enum CardControl {
        static func createSession() -> Endpoint<OnDotSessionResponse> {
            return Endpoint(method: .post, path: "v4/card-accounts/advanced/sessions")
        }
    }
}
