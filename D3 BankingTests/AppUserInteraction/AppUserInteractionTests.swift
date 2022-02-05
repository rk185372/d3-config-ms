//
//  AppUserInteractionTests.swift
//  D3 BankingTests
//
//  Created by Chris Carranza on 12/7/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import XCTest
import RxSwift
import RxRelay
import RxTest
import RxBlocking
@testable import UserInteraction

final class AppUserInteractionTests: XCTestCase {
    
    private var scheduler: TestScheduler!
    private var touchEvents: BehaviorRelay<UIEvent>!
    private var appUserInteraction: AppUserInteraction!

    override func setUp() {
        scheduler = TestScheduler(initialClock: 0)
        touchEvents = BehaviorRelay(value: UIEvent())
        appUserInteraction = AppUserInteraction(touchEvents: touchEvents.asObservable())
    }
    
    func testUserInteractionFromTouchEvents() {
        scheduler.scheduleAt(10) {
            self.touchEvents.accept(UIEvent())
        }
        scheduler.scheduleAt(15) {
            self.touchEvents.accept(UIEvent())
        }
        
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 20) {
            self.appUserInteraction.userInteractions.map { _ in 0 }
        }
        
        XCTAssertRecordedElements(res.events, [0,0,0])
    }
    
    func testSyntheticUserInteractions() {
        scheduler.scheduleAt(10) {
            self.touchEvents.accept(UIEvent())
        }
        scheduler.scheduleAt(15) {
            self.appUserInteraction.triggerUserInteraction()
        }
        
        let res = scheduler.start(created: 0, subscribed: 0, disposed: 20) {
            self.appUserInteraction.userInteractions.map { _ in 0 }
        }
        
        XCTAssertRecordedElements(res.events, [0,0,0])
    }
}
