//
//  SessionExpirationManagerTests.swift
//  D3 BankingTests
//
//  Created by Chris Carranza on 12/12/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxRelay
import RxTest
import RxBlocking
@testable import SessionExpiration

final class SessionExpirationManagerTests: XCTestCase {
    
    private var scheduler: TestScheduler!
    private var touchEvents: BehaviorRelay<Date>!
    private var expirationManager: SessionExpirationManager!
    
    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        touchEvents = BehaviorRelay(value: scheduler.now)
        expirationManager = SessionExpirationManager(timeout: 180, touchObservable: touchEvents.asObservable(), scheduler: scheduler)
    }
    
    func testGivingCorrectStatusRange() {
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 200) {
            self.expirationManager.timeoutState
        }
        
        var expected:[SessionExpirationManager.State] = [.clear]
        expected += (0...119).reversed().map { SessionExpirationManager.State.warning(secondsRemaining: $0) }
        expected.append(.timeout)
        
        XCTAssertRecordedElements(res.events, expected)
    }
    
    func testResettingStatusWhenUserInteraction() {
        scheduler.scheduleAt(62) {
            self.touchEvents.accept(self.scheduler.now)
        }
        
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 250) {
            self.expirationManager.timeoutState
        }
        
        var expected:[SessionExpirationManager.State] = [.clear, .warning(secondsRemaining: 119), .clear]
        expected += (0...119).reversed().map { SessionExpirationManager.State.warning(secondsRemaining: $0) }
        expected.append(.timeout)
        
        XCTAssertRecordedElements(res.events, expected)
    }
}
