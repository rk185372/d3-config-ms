//
//  BiometricsAutoPromptManagerTests.swift
//  D3 BankingTests
//
//  Created by Chris Carranza on 10/5/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import XCTest
import RxSwift
import RxRelay
import RxTest
import RxBlocking
@testable import Biometrics

class BiometricsAutoPromptManagerTests: XCTestCase {
    
    private var scheduler: TestScheduler!
    private var standardHelper: BiometricsHelper!
    private var standardAutoPromptManager: BiometricsAutoPromptManager!
    private var observer: TestableObserver<Int>!
    private var disposable: Disposable!
    
    override func setUp() {
        super.setUp()
        
        scheduler = TestScheduler(initialClock: 0)
        standardHelper = TestBiometricsHelper(supportedBiometricType: .touchId, domainStateChanged: false, biometricAuthEnabled: true, biometricAuthNeedsEnabled: false)
        standardAutoPromptManager = BiometricsAutoPromptManager(biometricsHelper: standardHelper)
        observer = scheduler.createObserver(Int.self)
    }
    
    override func tearDown() {
        super.tearDown()
        
        disposable.dispose()
    }
    
    func testPromptsWhenBiometricsEnabled() {
        disposable = standardAutoPromptManager.autoPrompt.asObservable().map { _ in 1 }.subscribe(observer)
        
        scheduler.start()
        
        standardAutoPromptManager.didRecieveInitialChallenge()
        standardAutoPromptManager.primaryViewVisible(true)
        
        XCTAssertRecordedElements(observer.events, [1])
    }
    
    func testDoesntPromptWhenBiometricsDisabled() {
        let helper = TestBiometricsHelper(supportedBiometricType: .touchId, domainStateChanged: false, biometricAuthEnabled: false, biometricAuthNeedsEnabled: false)
        let autoPromptManager = BiometricsAutoPromptManager(biometricsHelper: helper)
        
        disposable = autoPromptManager.autoPrompt.asObservable().map { _ in 1 }.subscribe(observer)
        
        scheduler.start()
        
        autoPromptManager.didRecieveInitialChallenge()
        autoPromptManager.primaryViewVisible(true)
        
        XCTAssertRecordedElements(observer.events, [])
    }
    
    func testDoesntPromptWhenLoggingOut() {
        let autoPromptManager = BiometricsAutoPromptManager(biometricsHelper: standardHelper, suppressPrompt: true)
        disposable = autoPromptManager.autoPrompt.asObservable().map { _ in 1 }.subscribe(observer)
        
        scheduler.start()
        
        standardAutoPromptManager.didRecieveInitialChallenge()
        standardAutoPromptManager.primaryViewVisible(true)
        
        XCTAssertRecordedElements(observer.events, [])
    }
    
    func testDoesntPromptWhenPrimaryViewNotVisible() {
        disposable = standardAutoPromptManager.autoPrompt.asObservable().map { _ in 1 }.subscribe(observer)
        
        scheduler.start()
        
        standardAutoPromptManager.didRecieveInitialChallenge()
        standardAutoPromptManager.primaryViewVisible(false)
        
        XCTAssertRecordedElements(observer.events, [])
    }
    
    func testDoesntPromptWhenHaventReceivedInitialChallenge() {
        disposable = standardAutoPromptManager.autoPrompt.asObservable().map { _ in 1 }.subscribe(observer)
        
        scheduler.start()
        
        standardAutoPromptManager.primaryViewVisible(true)
        
        XCTAssertRecordedElements(observer.events, [])
    }
    
    func testPromptsWhenOnPrimaryViewEnteringForeground() {
        disposable = standardAutoPromptManager.autoPrompt.asObservable().map { _ in 1 }.subscribe(observer)
        
        scheduler.start()
        
        standardAutoPromptManager.didRecieveInitialChallenge()
        standardAutoPromptManager.primaryViewVisible(true)
        standardAutoPromptManager.biometricsPromptShown()
        standardAutoPromptManager.willEnterForegroud()
        
        XCTAssertRecordedElements(observer.events, [1,1])
    }
    
    func testDoesntPromptLeavingPrimaryViewAndReturning() {
        disposable = standardAutoPromptManager.autoPrompt.asObservable().map { _ in 1 }.subscribe(observer)
        
        scheduler.start()
        
        standardAutoPromptManager.didRecieveInitialChallenge()
        standardAutoPromptManager.primaryViewVisible(true)
        standardAutoPromptManager.transitionedPastPrimaryView()
        
        standardAutoPromptManager.didRecieveInitialChallenge()
        standardAutoPromptManager.primaryViewVisible(true)
        
        XCTAssertRecordedElements(observer.events, [1])
    }
}
