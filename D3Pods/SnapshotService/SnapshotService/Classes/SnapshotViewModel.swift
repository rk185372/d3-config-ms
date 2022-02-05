//
//  SnapshotViewModel.swift
//  Snapshot
//
//  Created by Andrew Watt on 8/14/18.
//

import Foundation
import Logging
import RxCocoa
import RxSwift
import Snapshot
import Utilities

public final class SnapshotViewModel {
    public enum Value {
        case none
        case snapshot(snapshot: Snapshot)
        case detail(account: Snapshot.Account, transactions: [Snapshot.Transaction]?)
        case widget(widget: SnapshotWidget)
        case error(error: Error)
    }
    
    private let service: SnapshotService
    private let token: String
    private let uuid: String
    
    private let bag = DisposeBag()
    private let maxRetryCount = 12
    private let retryDelay: DispatchTimeInterval = .seconds(5)
    private let scheduler = SerialDispatchQueueScheduler(internalSerialQueueName: "\(SnapshotViewModel.self).scheduler")
    
    private let snapshotRelay = BehaviorRelay(value: Value.none)
    public var snapshot: Driver<Value> {
        return snapshotRelay.asDriver()
    }

    private let transactionsRelay = BehaviorRelay(value: Value.none)
    public var transactions: Driver<Value> {
        return transactionsRelay.asDriver()
    }

    private let widgetRelay = BehaviorRelay(value: Value.none)
    public var snapshotWidget: Driver<Value> {
        return widgetRelay.asDriver()
    }

    public var selectedAccount: Snapshot.Account? {
        willSet {
            guard let account = newValue else { return }
            self.fetchTransactions(for: account)
        }
    }

    public init(service: SnapshotService, token: String, uuid: String) {
        self.service = service
        self.token = token
        self.uuid = uuid
    }

    public func fetch() {
        if case .error = snapshotRelay.value {
            snapshotRelay.accept(.none)
        }

        retryingSnapshot().subscribe { [unowned self] (event) in
            switch event {
            case .success(let snapshot):
                self.snapshotRelay.accept(.snapshot(snapshot: snapshot))
                if snapshot.isSingleAccount, let account = snapshot.accounts.first {
                    self.transactionsRelay.accept(.detail(account: account, transactions: account.transactions))
                }
                
            case .error(let error):
                log.error("Error fetching snapshot: \(error)", context: error)
                self.snapshotRelay.accept(.error(error: error))
                self.transactionsRelay.accept(.error(error: error))
            }
        }.disposed(by: bag)
    }

    public func fetchTransactions(for account: Snapshot.Account) {
        guard let link = account.accountTransactionsLink else {
            self.transactionsRelay.accept(.detail(account: account, transactions: nil))
            return
        }
        service.getTransactions(token: token, uuid: uuid, urlPath: link)
            .subscribe(onSuccess: { [unowned self] (transactions) in
                self.transactionsRelay.accept(.detail(account: account, transactions: transactions))
        }, onError: { [unowned self] (error) in
            log.error(error)
            self.transactionsRelay.accept(.error(error: error))
        }).disposed(by: bag)
    }

    public func fetchWidget() {
        if case .error = snapshotRelay.value {
            snapshotRelay.accept(.none)
        }

        retryingWidgetSnapshot().subscribe { [unowned self] (event) in
            switch event {
            case .success(let widget):
               self.widgetRelay.accept(.widget(widget: widget))
                
            case .error(let error):
                log.error(error)
                self.widgetRelay.accept(.error(error: error))
            }
        }.disposed(by: bag)
    }
    
    private func retryingWidgetSnapshot(attemptCount: Int = 1) -> Single<SnapshotWidget> {
        
        log.debug("Widget fetch attempt: \(attemptCount)")
        
        return service
            .getWidget(token: token, uuid: uuid)
            .flatMap { (snapshotWidget) in
                switch snapshotWidget.syncStatus {
                case .failed:
                    throw SnapshotError.sync(status: snapshotWidget.syncStatus)
                case .success:
                    return .just(snapshotWidget)
                case .pending:
                    if attemptCount >= self.maxRetryCount {
                        throw SnapshotError.sync(status: snapshotWidget.syncStatus)
                    }
                }

                return Observable
                    .deferred { self.retryingWidgetSnapshot(attemptCount: attemptCount + 1).asObservable() }
                    .delaySubscription(self.retryDelay, scheduler: self.scheduler)
                    .asSingle()
        }
    }
    
    private func retryingSnapshot(attemptCount: Int = 1) -> Single<Snapshot> {
        log.debug("Snapshot fetch attempt: \(attemptCount)")
        return service
            .getSnapshot(token: token, uuid: uuid).flatMap { (snapshot) in
                switch snapshot.syncStatus {
                case .failed:
                    throw SnapshotError.sync(status: snapshot.syncStatus)
                case .success:
                    return .just(snapshot)
                case .pending:
                    if attemptCount >= self.maxRetryCount {
                        throw SnapshotError.sync(status: snapshot.syncStatus)
                    }
                }

                return Observable
                    .deferred { self.retryingSnapshot(attemptCount: attemptCount + 1).asObservable() }
                    .delaySubscription(self.retryDelay, scheduler: self.scheduler)
                    .asSingle()
        }
    }
}

public enum SnapshotError: Error {
    case sync(status: SnapshotSyncStatus)
}
