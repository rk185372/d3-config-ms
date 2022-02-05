//
//  AccountsService.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 5/16/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import D3Accounts
import Foundation
import Network
import RxSwift

protocol AccountsService {
    func getAccounts() -> Single<[AccountSection]>
    func getAccount(withId id: Int) -> Single<Account>
    func getAccountAttributes(forAccountWithId id: Int) -> Single<[AccountAttribute]>
    func getCards(forAccountWithId id: Int) -> Single<[Card]>
    func activateCard(withId cardId: String, forAccountWithId accountId: Int) -> Single<Card>
    func deactivateCard(withId cardId: String, forAccountWithId accountId: Int) -> Single<Card>
    func stopSinglePayment(_ payment: StoppedPayment, forAccountWithId id: Int) -> Single<StopPaymentResponse>
    func stopRangeOfPayments(_ paymentRange: StoppedRange, forAccountWithId id: Int) -> Single<StopPaymentResponse>
    func getStoppedPaymentHistory(forAccountWithId accountId: Int) -> Single<[StoppedPaymentHistoryItem]>
    func openExternalAccount() -> Single<OpenANewAccountResponse>
    func getOfflineAccountProducts() -> Single<[RawAccountProduct]>
    func saveOfflineAccount(account: OfflineAccount) -> Single<Data>
}
