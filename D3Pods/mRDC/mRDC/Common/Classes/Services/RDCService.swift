//
//  RDCServices.swift
//  mRDC
//
//  Created by Chris Pflepsen on 8/9/18.
//

import Network
import RxSwift

public protocol RDCService {
    func getDepositAccounts(withUuid uuid: String) -> Single<DepositAccountListResponse>
    func depositCheck(_ depositRequest: RDCRequest) -> Single<RDCResponse>
    func getHistory(withUuid uuid: String) -> Single<[DepositTransaction]>
    func getDepositTransactionImages(transaction: DepositTransaction, withUuid uuId: String) -> Single<[RDCImageData]>
}
