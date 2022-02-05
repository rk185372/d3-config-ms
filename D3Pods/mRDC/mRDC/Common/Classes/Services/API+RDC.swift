//
//  API+RDC.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/9/18.
//

import Foundation
import Network
import Wrap

extension API {
    enum RDC {
        static func getDepositAccounts(withUuid uuId: String) -> Endpoint<DepositAccountListResponse> {
            return Endpoint<DepositAccountListResponse>(method: .get, path: "v4/deposits/rdc", parameters: ["uuId": uuId])
        }
        
        static func depositCheck(_ request: Data) -> Endpoint<RDCResponse> {
            return Endpoint<RDCResponse>(method: .post, path: "v4/deposits", parameters: request)
        }
        
        static func getHistory(withUuid uuId: String) -> Endpoint<[DepositTransaction]> {
            return Endpoint<[DepositTransaction]>(method: .get, path: "v4/deposits", parameters: ["uuId": uuId])
        }
        
        static func getDepositImages(transaction: DepositTransaction, withUuid uuId: String) -> Endpoint<[RDCImageData]> {
            return Endpoint<[RDCImageData]>(
                method: .get,
                path: "v3/deposits/\(transaction.transactionId)/images",
                parameters: ["uuId": uuId, "itemImageAngle": "BOTH", "sequenceNumber": 1]
            )
        }
    }
}
