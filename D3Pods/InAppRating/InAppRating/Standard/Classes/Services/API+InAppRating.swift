//
//  API+InAppRating.swift
//  InAppRating
//
//  Created by Chris Carranza on 4/9/19.
//

import Foundation
import Network
import Utilities

extension API {
    enum InAppRating {
        static func shouldPrompt() -> Endpoint<ShouldPromptResponse> {
            return Endpoint(path: "v4/app-rating/should-prompt")
        }
        
        static func userPrompted(_ promptedRequest: UserPromptedRequest) -> Endpoint<Void> {
            return Endpoint(
                method: .post,
                path: "v4/app-rating/user-prompted",
                parameters: try! promptedRequest.dictEncode()
            )
        }
    }
}
