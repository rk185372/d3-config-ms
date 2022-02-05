//
//  MessageStatsManagerTests.swift
//  D3 BankingTests
//
//  Created by Chris Carranza on 12/3/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import XCTest
import RxSwift
import RxRelay
import RxTest
import RxBlocking
@testable import Messages
@testable import Session

final class MessageStatsManagerTests: XCTestCase {

    private var scheduler: TestScheduler!
    private var messagesService: TestMessagesService!
    private var messageStatsManager: MessageStatsManager!
    private var touchObservable: BehaviorRelay<Date>!
    private var userSession: UserSession!
    private var bag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        
        bag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        messagesService = TestMessagesService(alertsStatsResponseCount: 2, secureMessageStatsResponseCount: 2, approvalsStatsResponseCount: 0)
        touchObservable = BehaviorRelay(value: scheduler.now)
        userSession = UserSession()
        userSession.rawSession = rawSession()
        
        messageStatsManager = MessageStatsManager(
            serviceItem: messagesService,
            touchObservable: touchObservable.asObservable(),
            userSession: userSession,
            scheduler: scheduler
        )
    }
    
    override func tearDown() {
        super.tearDown()
        
        bag = nil
    }

    func testGettingAlertsCountFromService() {
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 20) {
            self.messageStatsManager.alertsCount
        }

        XCTAssertRecordedElements(res.events, [2])
    }
    
    func testGettingSecureMessageCountFromService() {
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 20) {
            self.messageStatsManager.secureMessageCount
        }
        
        XCTAssertRecordedElements(res.events, [2])
    }

    func testAlertsCountFromWebRelay() {
        scheduler.scheduleAt(15) {
            self.messagesService.alertsStatsResponseCount = 4

            self.messageStatsManager.webUpdateTrigger.accept(())
        }
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 20) {
            self.messageStatsManager.alertsCount
        }

        XCTAssertRecordedElements(res.events, [2,4])
    }

    func testSecureMessageCountFromWebRelay() {
        scheduler.scheduleAt(15) {
            self.messagesService.secureMessageStatsResponseCount = 4
            
            self.messageStatsManager.webUpdateTrigger.accept(())
        }
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 20) {
            self.messageStatsManager.secureMessageCount
        }
        
        XCTAssertRecordedElements(res.events, [2,4])
    }
    
    func testProfileChangeTriggersMessagesUpdate() {
        scheduler.scheduleAt(15) {
            self.userSession.selectProfile(index: 1)
            self.messagesService.secureMessageStatsResponseCount = 5
        }
        scheduler.scheduleAt(65) {
            self.simulateTouch()
        }
        
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 70) {
            self.messageStatsManager.secureMessageCount
        }
        
        XCTAssertRecordedElements(res.events, [2,0,2,5])
    }
    
    func testStopPollingDueToInactivityOnSecureMessages() {
        scheduler.scheduleAt(80) {
            self.messagesService.secureMessageStatsResponseCount = 10
        }
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 185) {
            self.messageStatsManager.secureMessageCount
        }
        
        // The network response 2, No other activity should occur after due to the
        // last touch now being set to one minute ago which is greater than the interaction time.
        XCTAssertRecordedElements(res.events, [2])
    }

    func testStopPollingDueToInactivityOnAlerts() {
        scheduler.scheduleAt(80) {
            self.messagesService.alertsStatsResponseCount = 10
        }
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 185) {
            self.messageStatsManager.alertsCount
        }

        // The network response 2, No other activity should occur after due to the
        // last touch now being set to one minute ago which is greater than the interaction time.
        XCTAssertRecordedElements(res.events, [2])
    }
    
    func testPollingWithDifferentValuesOnSecureMessages() {
        scheduler.scheduleAt(40) {
            self.messagesService.secureMessageStatsResponseCount = 5
        }
        scheduler.scheduleAt(65) {
            self.simulateTouch()
        }
        scheduler.scheduleAt(110) {
            self.messagesService.secureMessageStatsResponseCount = 8
        }
        scheduler.scheduleAt(125) {
            self.simulateTouch()
        }
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 190) {
            self.messageStatsManager.secureMessageCount
        }
        
        XCTAssertRecordedElements(res.events, [2,5,8])
    }

    func testPollingWithDifferentValuesOnAlerts() {
        scheduler.scheduleAt(40) {
            self.messagesService.alertsStatsResponseCount = 5
        }
        scheduler.scheduleAt(65) {
            self.simulateTouch()
        }
        scheduler.scheduleAt(110) {
            self.messagesService.alertsStatsResponseCount = 8
        }
        scheduler.scheduleAt(125) {
            self.simulateTouch()
        }
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 190) {
            self.messageStatsManager.alertsCount
        }

        XCTAssertRecordedElements(res.events, [2,5,8])
    }
    
    func testCombinedMessagesCountFromMultipleSources() {
        let testObserver = scheduler.createObserver(Int.self)
        messageStatsManager.secureMessageCount.subscribe(testObserver).disposed(by: bag)
        
        simulateNetworkRequest(3, 3) {
            self.simulateTouch()
        }
        XCTAssertRecordedElements(testObserver.events, [3])

        advanceTimeBy(80)
        simulateNetworkRequest(7, 7) {
            self.simulateWebTrigger()
        }
        XCTAssertRecordedElements(testObserver.events, [3,7])
        
        simulateNetworkRequest(8, 8) {
            self.userSession.selectProfile(index: 2)
        }
        
        XCTAssertRecordedElements(testObserver.events, [3,7,0,8])
        
        simulateNetworkRequest(10, 10) {
            self.simulateTouch()
        }
        XCTAssertRecordedElements(testObserver.events, [3,7,0,8,10])
        
        advanceTimeBy(245)
        XCTAssertRecordedElements(testObserver.events, [3,7,0,8,10])
        
        simulateNetworkRequest(15, 15) {
            self.simulateTouch()
        }
        XCTAssertRecordedElements(testObserver.events, [3,7,0,8,10,15])

        XCTAssertEqual(messagesService.secureMessagesNetworkCallCount, 5)
    }
    
    func testMultipleSubscriptionsOnSecureMessages() {
        let combinedTestObserver = scheduler.createObserver(Int.self)
        messageStatsManager.secureMessageCount.subscribe(combinedTestObserver).disposed(by: bag)

        simulateNetworkRequest(1, 1)

        XCTAssertRecordedElements(combinedTestObserver.events, [1])

        scheduler.advanceTo(80)
        simulateNetworkRequest(7, 7) {
            self.simulateWebTrigger()
        }

        XCTAssertRecordedElements(combinedTestObserver.events, [1,7])

        let noticesTestObserver = scheduler.createObserver(Int.self)
        messageStatsManager.secureMessageCount.subscribe(noticesTestObserver).disposed(by: bag)
        XCTAssertRecordedElements(noticesTestObserver.events, [7])

        scheduler.advanceTo(245)
        XCTAssertRecordedElements(combinedTestObserver.events, [1,7])

        simulateNetworkRequest(15, 15) {
            self.simulateTouch()
        }

        XCTAssertRecordedElements(combinedTestObserver.events, [1,7,15])
        XCTAssertRecordedElements(noticesTestObserver.events, [7,15])
        XCTAssertEqual(messagesService.secureMessagesNetworkCallCount, 3)
    }

    func testMultipleSubscriptionsOnAlerts() {
        let combinedTestObserver = scheduler.createObserver(Int.self)
        messageStatsManager.alertsCount.subscribe(combinedTestObserver).disposed(by: bag)

        simulateNetworkRequest(1, 1)

        XCTAssertRecordedElements(combinedTestObserver.events, [1])

        scheduler.advanceTo(80)
        simulateNetworkRequest(7, 7) {
            self.simulateWebTrigger()
        }

        XCTAssertRecordedElements(combinedTestObserver.events, [1,7])

        let noticesTestObserver = scheduler.createObserver(Int.self)
        messageStatsManager.secureMessageCount.subscribe(noticesTestObserver).disposed(by: bag)
        XCTAssertRecordedElements(noticesTestObserver.events, [7])

        scheduler.advanceTo(245)
        XCTAssertRecordedElements(combinedTestObserver.events, [1,7])

        simulateNetworkRequest(15, 15) {
            self.simulateTouch()
        }

        XCTAssertRecordedElements(combinedTestObserver.events, [1,7,15])
        XCTAssertRecordedElements(noticesTestObserver.events, [7,15])
        XCTAssertEqual(messagesService.secureMessagesNetworkCallCount, 3)
    }

    private func simulateNetworkRequest(_ alertsCount: Int, _ secureMessagesCount: Int, trigger: (() -> Void)? = nil) {
        messagesService.secureMessageStatsResponseCount = secureMessagesCount
        messagesService.alertsStatsResponseCount = alertsCount
        trigger?()

        // We need to post network responses so they act like real life.
        // This advances the scheduler, just like it would in production.
        advanceTimeBy(1)
    }
    
    private func advanceTimeBy(_ time: Int) {
        scheduler.advanceTo(scheduler.adjustScheduledTime(time))
    }
    
    private func simulateWebTrigger() {
        messageStatsManager.webUpdateTrigger.accept(())
    }
    
    private func simulateTouch() {
        touchObservable.accept(scheduler.now)
    }

    private func rawSession() -> RawSession {
        let data = try! Data(
            contentsOf: URL(
                fileURLWithPath: "SampleUserSession.json",
                relativeTo: Bundle(for: type(of: self)).bundleURL
            ),
            options: .alwaysMapped
        )

        return try! JSONDecoder().decode(RawSession.self, from: data)
    }
}
