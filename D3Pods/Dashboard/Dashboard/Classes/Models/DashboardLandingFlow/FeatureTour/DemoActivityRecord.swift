//
//  DemoActivityRecord.swift
//  Dashboard
//
//  Created by Pablo Pellegrino on 20/10/2021.
//

import Foundation

public struct DemoActivityRecord: Decodable {
    let id: Int
    let createdAt: String
    let type: String
    let participantId: String
}
