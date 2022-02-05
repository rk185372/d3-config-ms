//
//  UserPromptedRequest.swift
//  InAppRating
//
//  Created by Chris Carranza on 4/9/19.
//

import Foundation

struct UserPromptedRequest: Codable {
    let promptedLocation: String
    let agreedToRate: Bool
}
