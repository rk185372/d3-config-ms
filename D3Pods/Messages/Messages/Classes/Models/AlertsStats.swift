//
//  AlertsStats.swift
//  Messages
//
//  Created by Branden Smith on 9/6/18.
//

import Foundation

public struct AlertsStats: Decodable {
    let new: Int

    enum CodingKeys: String, CodingKey {
        case new = "NEW"
    }
    
    public init(new: Int) {
        self.new = new
    }
}
