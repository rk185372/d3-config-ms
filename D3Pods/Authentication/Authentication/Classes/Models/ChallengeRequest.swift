//
//  ChallengeRequest.swift
//  Authentication
//
//  Created by Chris Carranza on 6/21/18.
//

import Foundation

public final class ChallengeRequest {
    let type: String?
    var items: [ChallengeItem]
    let isAuthenticated: Bool
    let token: String?
    let previousItems: [[String: Any]]?
    
    public init(_ challengeResponse: ChallengeResponse) {
        self.type = challengeResponse.type
        self.items = challengeResponse.items
        self.isAuthenticated = challengeResponse.isAuthenticated
        self.token = challengeResponse.token
        self.previousItems = challengeResponse.previousItems
    }
}
