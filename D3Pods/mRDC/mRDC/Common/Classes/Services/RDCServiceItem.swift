//
//  RDCServiceItem.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/9/18.
//

import Foundation
import Network
import RxSwift

public enum RDCServiceError: Error {
    case failedToSerializeRequest
}

public final class RDCServiceItem: RDCService {

    let client: ClientProtocol

    public init(client: ClientProtocol) {
        self.client = client
    }
    
    public func getDepositAccounts(withUuid uuid: String) -> Single<DepositAccountListResponse> {
        return client.request(API.RDC.getDepositAccounts(withUuid: uuid))
    }
    
    public func depositCheck(_ depositRequest: RDCRequest) -> Single<RDCResponse> {
        guard let request = depositRequest.asData() else {
            return Single.error(RDCServiceError.failedToSerializeRequest)
        }
        
        return client.request(API.RDC.depositCheck(request), acceptableStatusCodes: Array(100..<600))
    }

    public func getHistory(withUuid uuid: String) -> Single<[DepositTransaction]> {
        return client.request(API.RDC.getHistory(withUuid: uuid))
    }

    public func getDepositTransactionImages(transaction: DepositTransaction, withUuid uuId: String) -> Single<[RDCImageData]> {
        return client.request(API.RDC.getDepositImages(transaction: transaction, withUuid: uuId))
    }
}
