//
//  API+Accounts.swift
//  AccountsPresentation
//
//  Created by Chris Carranza on 1/15/18.
//

import D3Accounts
import Foundation
import Network
import Wrap

extension API {
    enum Accounts {
        static func getAccounts() -> Endpoint<AccountsListResponse> {
            return Endpoint<AccountsListResponse>(path: "v4/accounts")
        }

        static func getAccount(withId id: Int) -> Endpoint<Account> {
            return Endpoint<Account>(path: "v4/accounts/\(id)")
        }

        static func getAccountAttributes(forAccountWithId id: Int) -> Endpoint<AccountAttributesResponse> {
            return Endpoint<AccountAttributesResponse>(path: "v4/accounts/\(id)/attributes/formatted")
        }

        static func getCards(forAccountWithId id: Int) -> Endpoint<CardControlsResponse> {
            return Endpoint<CardControlsResponse>(path: "v4/card-accounts/\(id)")
        }

        static func activateCard(withId cardId: String, forAccountWithId accountId: Int) -> Endpoint<Card> {
            return Endpoint<Card>(method: .post, path: "v4/card-accounts/\(accountId)/cards/\(cardId)/activate")
        }

        static func deactivateCard(withId cardId: String, forAccountWithId accountId: Int) -> Endpoint<Card> {
            return Endpoint<Card>(method: .post, path: "v4/card-accounts/\(accountId)/cards/\(cardId)/deactivate")
        }

        static func stopPayment(_ payment: StoppedPayment, forAccountWithId accountId: Int) -> Endpoint<StopPaymentResponse> {
            return Endpoint<StopPaymentResponse>(
                method: .post,
                path: "v4/accounts/\(accountId)/stopPayments/single",
                parameters: try? wrap(payment)
            )
        }

        static func stopRangeOfPayments(_ paymentRange: StoppedRange, forAccountWithId accountId: Int) -> Endpoint<StopPaymentResponse> {
            return Endpoint<StopPaymentResponse>(
                method: .post,
                path: "v4/accounts/\(accountId)/stopPayments/range",
                parameters: try? wrap(paymentRange)
            )
        }

        static func getStoppedPaymentHistory(forAccountWithId accountId: Int) -> Endpoint<[StoppedPaymentHistoryItem]> {
            return Endpoint<[StoppedPaymentHistoryItem]>(path: "v4/accounts/\(accountId)/stopPayments/history")
        }

        static func openExternalAccount() -> Endpoint<OpenANewAccountResponse> {
            return Endpoint<OpenANewAccountResponse>(method: .post, path: "v3/external/open-account")
        }

        static func getOfflineAccountProducts() -> Endpoint<[RawAccountProduct]> {
            return Endpoint<[RawAccountProduct]>(path: "v3/accountProducts", parameters: ["source": "OFFLINE"])
        }

        static func saveOfflineAccount(account: OfflineAccount) -> Endpoint<Data> {
            return Endpoint<Data>(method: .post, path: "v3/accounts", parameters: account.asData())
        }
    }
}
