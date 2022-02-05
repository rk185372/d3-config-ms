//
//  SnapshotSyncStatus.swift
//  Snapshot
//
//  Created by Andrew Watt on 8/17/18.
//

import Foundation

public enum SnapshotSyncStatus: String, Decodable {
    case pending = "PENDING"
    case success = "SUCCESS"
    case failed = "FAILED"
}

extension SnapshotSyncStatus {
    public var errorMessageKey: String {
        switch self {
        case .pending:
            return "launchPage.snapshot.status-active"
        case .success:
            return "launchPage.snapshot.status-complete-success"
        default:
            return "launchPage.snapshot.unexpected-error"
        }
    }
}
