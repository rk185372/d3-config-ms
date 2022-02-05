//
//  SwitchTabAlertConfirmation.swift
//  Pods
//
//  Created by Balaga, Satish on 3/4/21.
//

import Foundation

struct SwitchTabAlertConfirmation: Codable {
    let title: String?
    let message: String?
    let confirmTitle: String?
    let cancelTitle: String?

    public init(confirmation: [String: Any]) throws {
        self = try JSONDecoder().decode(
            SwitchTabAlertConfirmation.self,
            from: JSONSerialization.data(withJSONObject: confirmation)
        )
    }
}
