//
//  API+Challenge.swift
//  D3 Banking
//
//  Created by Chris Carranza on 1/16/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import Network
import Wrap

extension API {
    enum Challenge {
        static func challenges() -> Endpoint<Data> {
            return Endpoint(path: "v3/auth/challenge")
        }
        
        static func post(challenge: [String: Any], headers: [String: String]?) -> Endpoint<Data> {
            return Endpoint(.init(method: .post, path: "v3/auth/challenge", headers: headers, parameters: challenge))
        }

        static func cancel(challenge: [String: Any]) -> Endpoint<Data> {
            return Endpoint(method: .post, path: "v3/auth/challenge/cancel", parameters: challenge)
        }

        static func back(challenge: [String: Any]) -> Endpoint<Data> {
            return Endpoint(method: .post, path: "v3/auth/challenge/back", parameters: challenge)
        }
        
        static func launchPageItems(profileType: String) -> Endpoint<LaunchItemsResponse> {
            if !profileType.isEmpty {
                return Endpoint(method: .get, path: "v3/view/quick", parameters: ["profileType": profileType])
            }
            
            return Endpoint(path: "v3/view/quick")
        }
    }
}
