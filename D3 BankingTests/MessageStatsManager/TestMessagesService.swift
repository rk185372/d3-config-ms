//
//  TestMessagesService.swift
//  D3 BankingTests
//
//  Created by Chris Carranza on 12/3/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
@testable import Messages
import RxSwift
import RxRelay

final class TestMessagesService: MessagesService {
    
    var alertsStatsResponseCount: Int {
        get { return alertsStatsResponse.new }
        set { alertsStatsResponse = AlertsStats(new: newValue) }
    }

    var secureMessageStatsResponseCount: Int {
        get { return secureMessageStatsResponse.replied }
        set { secureMessageStatsResponse = SecureMessageStats(replied: newValue) }
    }

    private(set) var alertsNetworkCallCount: Int = 0
    private(set) var secureMessagesNetworkCallCount: Int = 0
    private(set) var approvalsNetworkCallCount: Int = 0

    private var secureMessageStatsResponse: SecureMessageStats
    private var alertsStatsResponse: AlertsStats
    private var approalStatsResponse: ApprovalsStats
    
    init(alertsStatsResponseCount: Int, secureMessageStatsResponseCount: Int, approvalsStatsResponseCount: Int) {
        self.alertsStatsResponse = AlertsStats(new: alertsStatsResponseCount)
        self.secureMessageStatsResponse = SecureMessageStats(replied: secureMessageStatsResponseCount)
        self.approalStatsResponse = ApprovalsStats(pending: approvalsStatsResponseCount, approved: 0, canceled: 0, expired: 0, rejected: 0)
    }

    func getAlertsStats() -> Single<AlertsStats> {
        return Single.just(alertsStatsResponse).do(onSuccess: { _ in
            self.alertsNetworkCallCount += 1
        })
    }
    
    func getSecureMessageStats() -> Single<SecureMessageStats> {
        return Single.just(secureMessageStatsResponse).do(onSuccess: { _ in
            self.secureMessagesNetworkCallCount += 1
        })
    }
    
    func getApprovalsStats() -> Single<ApprovalsStats> {
        return Single.just(approalStatsResponse).do(onSuccess: { _ in
            self.approvalsNetworkCallCount += 1
        })
    }
}
