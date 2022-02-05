//
//  SecureMessageStats.swift
//  Messages
//
//  Created by Branden Smith on 9/6/18.
//

import Foundation

public struct SecureMessageStats: Decodable {
    let replied: Int

    enum CodingKeys: String, CodingKey {
        case replied = "REPLIED"
    }
    
    public init(replied: Int) {
        self.replied = replied
    }
}
