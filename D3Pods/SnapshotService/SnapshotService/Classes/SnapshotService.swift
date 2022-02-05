//
//  SnapshotService.swift
//  QuickView
//
//  Created by Chris Carranza on 1/15/18.
//

import Foundation
import Transactions
import RxSwift
import Snapshot
import Utilities

public protocol SnapshotService {
    func getSnapshot(token: String, uuid: String) -> Single<Snapshot>
    func getTransactions(token: String, uuid: String, urlPath: String) -> Single<[Snapshot.Transaction]>
    func getWidget(token: String, uuid: String) -> Single<SnapshotWidget>
}
