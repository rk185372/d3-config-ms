//
//  API+Snapshot.swift
//  QuickView
//
//  Created by Chris Carranza on 1/8/18.
//

import Foundation
import Network
import Snapshot
import Utilities

public extension API {
    enum QuickView {
        public static func getSnapshot(token: String, uuid: String) -> Endpoint<Snapshot> {
            let parameters = self.parameters(forToken: token, uuid: uuid)
            return Endpoint(method: .post, path: "v4/anon/view/quick", parameters: parameters)
        }

        public static func getTransactions(token: String, uuid: String, urlPath: String) -> Endpoint<[Snapshot.Transaction]> {
            let parameters = self.parameters(forToken: token, uuid: uuid)
            return Endpoint(method: .post, path: urlPath, parameters: parameters)
        }

        public static func getWidget(token: String, uuid: String) -> Endpoint<SnapshotWidget> {
            let parameters = self.parameters(forToken: token, uuid: uuid)
            return Endpoint(method: .post, path: "v4/anon/view/quick/widget", parameters: parameters)
        }
        
        private static func parameters(forToken token: String, uuid: String) -> Parameters {
            return [
                "snapshotToken": token,
                "deviceUuid": uuid
            ]
        }
    }
}
