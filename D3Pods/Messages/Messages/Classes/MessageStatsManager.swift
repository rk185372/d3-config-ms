//
//  MessageStatsManager.swift
//  Messages
//
//  Created by Branden Smith on 9/6/18.
//

import Foundation
import Network
import RxSwift
import RxRelay
import Session
import Utilities

public final class MessageStatsManager {
    private struct StatsCount: Equatable {
        public let alertsCount: Int
        public let secureMessageCount: Int
        public let approvalCounts: Int
    }
    
    private struct PollingInfo {
        var lastTouch: Date
        var lastPole: Date?
    }

    private static let pollingTimeInSeconds: TimeInterval = 60.0
    private static let interactionRequiredTimeInSeconds: TimeInterval = 60.0

    public let webUpdateTrigger: PublishRelay<Void> = PublishRelay()
    public let secureMessageCount: Observable<Int>
    public let alertsCount: Observable<Int>
    public let approvalsCount: Observable<Int>

    public init(serviceItem: MessagesService,
                touchObservable: Observable<Date>,
                userSession: UserSession,
                scheduler: SchedulerType = MainScheduler.instance) {
        let profileChangeObservable = userSession.rx.selectedProfileIndex.mapToVoid().skip(1)

        let timer = Observable<Int>
            .timer(.seconds(0), period: .seconds(1), scheduler: scheduler)

        let triggerWhenUserInteraction = Observable
            .combineLatest(timer, touchObservable) { PollingInfo(lastTouch: $1, lastPole: nil) }
            .scan(PollingInfo(lastTouch: scheduler.now, lastPole: nil), accumulator: { (old, new) -> PollingInfo in
                let now = scheduler.now
                var mutableOld = old
                var mutableNew = new
                
                if old.lastPole == nil {
                    // Poll now if we haven't polled before.
                    mutableNew.lastPole = now
                    return mutableNew
                }
                
                if now.timeIntervalSince(old.lastPole!) > MessageStatsManager.pollingTimeInSeconds
                    && now.timeIntervalSince(new.lastTouch) < MessageStatsManager.interactionRequiredTimeInSeconds {
                    // Poll again if:
                    // - It's been at least pollingTimeInSeconds since the last poll
                    // - The user has interacted within interactionRequiredTimeInSeconds
                    mutableNew.lastPole = now
                    return mutableNew
                }
                
                mutableOld.lastTouch = new.lastTouch
                return mutableOld
            })
            .skipNilMapResult(keyPath: \.lastPole)
            .distinctUntilChanged()
            .mapToVoid()
        
        let combinedTrigger = Observable
            .merge(
                triggerWhenUserInteraction,
                webUpdateTrigger.asObservable(),
                profileChangeObservable.asObservable()
            )
            .share(replay: 1)
        
        let netMessageCount = combinedTrigger
            .filter({ userSession.rawSession != nil })
            .flatMap { _ in
                Observable
                    .zip(
                        serviceItem
                            .getAlertsStats()
                            .map { (alertStats: AlertsStats) in
                                Result { alertStats }
                            }
                            .catchError { error in
                                Single.just(Result { throw error })
                            }
                            .asObservable(),
                        serviceItem
                            .getSecureMessageStats()
                            .map { (messageStats: SecureMessageStats) in
                                Result { messageStats }
                            }
                            .catchError { error in
                                Single.just(Result { throw error })
                            }
                            .asObservable(),
                        serviceItem
                            .getApprovalsStats()
                            .map { (approvalsStats: ApprovalsStats) in
                                Result { approvalsStats }
                            }
                            .catchError { error in
                                Single.just(Result { throw error })
                            }
                            .asObservable()
                )
            }
            .map { observables -> StatsCount in
                let (alertStats, secureMessageStats, approvalsStats) = observables

                return StatsCount(
                    alertsCount: alertStats.value?.new ?? 0,
                    secureMessageCount: secureMessageStats.value?.replied ?? 0,
                    approvalCounts: approvalsStats.value?.pending ?? 0
                )
            }
        
        let profileChangeMessageCount = profileChangeObservable
            .map { _ in StatsCount(alertsCount: 0, secureMessageCount: 0, approvalCounts: 0) }

        let netAndProfileChange = Observable
            .merge(profileChangeMessageCount, netMessageCount)
            .share(replay: 1)
            .distinctUntilChanged()

        alertsCount = netAndProfileChange
            .map { $0.alertsCount }
            .share(replay: 1)
        
        secureMessageCount = netAndProfileChange
            .map { $0.secureMessageCount }
            .share(replay: 1)
        
        approvalsCount = netAndProfileChange
            .map { $0.approvalCounts }
            .share(replay: 1)
    }
}
