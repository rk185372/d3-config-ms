//
//  DeviceInfoResponse.swift
//  DeviceInfoService
//
//  Created by Chris Carranza on 8/15/18.
//

import Foundation

public struct DeviceInfoResponse: Codable, Equatable {
    public var authTokenExists: Bool
    public var snapshotTokenExists: Bool
    public var id: Int
    
    public init(authTokenExists: Bool, snapshotTokenExists: Bool, id: Int) {
        self.authTokenExists = authTokenExists
        self.snapshotTokenExists = snapshotTokenExists
        self.id = id
    }
}
