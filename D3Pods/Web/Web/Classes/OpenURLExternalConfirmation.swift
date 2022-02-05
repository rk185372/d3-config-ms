//
//  OpenURLExternalConfirmation.swift
//  Web
//
//  Created by Elvin Bearden on 7/30/20.
//

import Foundation

struct OpenURLExternalConfirmation: Codable {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String

    public init(confirmation: [String: Any]) throws {
        self = try JSONDecoder().decode(
            OpenURLExternalConfirmation.self,
            from: JSONSerialization.data(withJSONObject: confirmation)
        )
    }
}
