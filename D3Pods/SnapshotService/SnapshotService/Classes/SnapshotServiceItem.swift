//
//  SnapshotServiceItem.swift
//  QuickView
//
//  Created by Chris Carranza on 1/15/18.
//

import Foundation
import Network
import RxSwift
import Snapshot
import Transactions
import Utilities

public final class SnapshotServiceItem: SnapshotService {
    let client: ClientProtocol
    
    public init(client: ClientProtocol) {
        self.client = client
    }
    
    public func getSnapshot(token: String, uuid: String) -> Single<Snapshot> {
        return client.request(API.QuickView.getSnapshot(token: token, uuid: uuid))
    }

    public func getTransactions(token: String, uuid: String, urlPath: String) -> Single<[Snapshot.Transaction]> {
        return client.request(API.QuickView.getTransactions(token: token, uuid: uuid, urlPath: urlPath))
    }

    public func getWidget(token: String, uuid: String) -> Single<SnapshotWidget> {
        return client.request(API.QuickView.getWidget(token: token, uuid: uuid))
    }
}

enum SnapshotServiceError: Error {
    case snapshotUnavailable
}
