//
//  ErrorMessageResponse.swift
//  Network
//
//  Created by Chris Carranza on 1/24/18.
//

import Foundation

struct ErrorMessageResponse: Codable {
    let message: String
    let code: String?
}
