//
//  AccountsServiceItem.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 11/29/17.
//

import D3Accounts
import Foundation
import Network
import RxSwift

public final class AccountsServiceItem: AccountsService {
    
    let client: ClientProtocol
    
    init(client: ClientProtocol) {
        self.client = client
    }

    func getAccounts() -> Single<[AccountSection]> {
        return client
            .request(API.Accounts.getAccounts())
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ response in
                AccountsServiceBridge().convert(serverResponse: response)
            })
            .observeOn(MainScheduler.instance)
    }

    func getAccount(withId id: Int) -> Single<Account> {
        return client.request(API.Accounts.getAccount(withId: id))
    }

    func getAccountAttributes(forAccountWithId id: Int) -> Single<[AccountAttribute]> {
        return client.request(API.Accounts.getAccountAttributes(forAccountWithId: id)).map({ response in response.attributes })
    }

    func getCards(forAccountWithId id: Int) -> Single<[Card]> {
        return client.request(API.Accounts.getCards(forAccountWithId: id)).map({ response in response.cards })
    }

    func activateCard(withId cardId: String, forAccountWithId accountId: Int) -> Single<Card> {
        return client.request(API.Accounts.activateCard(withId: cardId, forAccountWithId: accountId))
    }

    func deactivateCard(withId cardId: String, forAccountWithId accountId: Int) -> Single<Card> {
        return client.request(API.Accounts.deactivateCard(withId: cardId, forAccountWithId: accountId))
    }

    func stopSinglePayment(_ payment: StoppedPayment, forAccountWithId id: Int) -> Single<StopPaymentResponse> {
        return client.request(API.Accounts.stopPayment(payment, forAccountWithId: id))
    }

    func stopRangeOfPayments(_ paymentRange: StoppedRange, forAccountWithId id: Int) -> Single<StopPaymentResponse> {
        return client.request(API.Accounts.stopRangeOfPayments(paymentRange, forAccountWithId: id))
    }

    func getStoppedPaymentHistory(forAccountWithId accountId: Int) -> Single<[StoppedPaymentHistoryItem]> {
        return client.request(API.Accounts.getStoppedPaymentHistory(forAccountWithId: accountId))
    }

    func openExternalAccount() -> Single<OpenANewAccountResponse> {
        return client.request(API.Accounts.openExternalAccount())
    }

    func getOfflineAccountProducts() -> Single<[RawAccountProduct]> {
        return client.request(API.Accounts.getOfflineAccountProducts())
    }

    func saveOfflineAccount(account: OfflineAccount) -> Single<Data> {
        return client.request(API.Accounts.saveOfflineAccount(account: account))
    }
}
