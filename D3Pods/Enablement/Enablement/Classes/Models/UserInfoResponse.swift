//
//  UserInfoResponse.swift
//  Enablement
//
//  Created by Chris Carranza on 8/8/18.
//

import Foundation

public struct UserInfoResponse: Codable, Equatable {
    var authTokenExists: Bool
    var snapshotTokenExists: Bool
    var id: Int
}
