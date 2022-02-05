//
//  ProfileSyncOperation.swift
//  Session
//
//  Created by Andrew Watt on 10/11/18.
//

import Foundation

public struct ProfileSyncOperation: Codable, Equatable {
    public struct SyncOperation: Codable, Equatable {
        public var completeTimestamp: String?
        public var errorCode: String?
        public var errorMessage: String?
        public var id: Int?
        public var operation: String?
        public var retryNumber: Int?
        public var service: String?
        public var status: String?
        public var trackingId: String?
    }
    
    public var profileId: Int?
    public var syncOps: [SyncOperation]?
    public var trackingId: String?
}
