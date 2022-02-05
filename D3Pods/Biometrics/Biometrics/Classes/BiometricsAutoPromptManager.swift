//
//  BiometricsAutoPromptManager.swift
//  Biometrics
//
//  Created by Chris Carranza on 9/4/18.
//

import Foundation
import RxSwift
import RxCocoa
import BiometricKeychainAccess

/// Tracks the state of different attributes to
/// determine if device should autoPrompt biometrics.
///
/// Biometrics should autoprompt if biometrics is available,
/// and the user is on the login screen. The user should not
/// be prompted when logging out. When the user "backgrounds"
/// the app while on the login screen, it should reset the
/// tracker to autoprompt the user again.
public final class BiometricsAutoPromptManager {
    private var shouldPromptTracker: Bool = true
    
    private let biometricsHelper: BiometricsHelper
    private var _willEnterForeground = BehaviorRelay<Void>(value: ())
    private var _didRecieveInitialChallenge = BehaviorRelay<Bool>(value: false)
    private var _primaryViewVisible = BehaviorRelay<Bool>(value: false)
    
    /// Will trigger whenever biometrics should
    /// automatically prompt the user
    public private(set) var autoPrompt: Driver<Void>!
    
    public init(biometricsHelper: BiometricsHelper, suppressPrompt: Bool = false) {
        self.biometricsHelper = biometricsHelper
        self.shouldPromptTracker = !suppressPrompt
        
        autoPrompt = Observable.combineLatest(
            _willEnterForeground,
            _didRecieveInitialChallenge.asObservable(),
            _primaryViewVisible.asObservable()
        ).filter { [unowned self] (result) -> Bool in
            return result.1
                && result.2
                && self.shouldPromptTracker
                && biometricsHelper.biometricAuthEnabled
        }.map { _ in }
        .asDriver(onErrorJustReturn: ())
    }
    
    /// Call when the primary view is visible
    ///
    /// - Parameter visible: view is visible
    public func primaryViewVisible(_ visible: Bool) {
        _primaryViewVisible.accept(visible)
    }
    
    /// Call when the app enters the foreground and the
    /// login screen is displayed
    public func willEnterForegroud() {
        if _primaryViewVisible.value {
            shouldPromptTracker = true
        }
        _willEnterForeground.accept(())
    }
    
    /// Updates the state of the current challenge
    public func didRecieveInitialChallenge() {
        _didRecieveInitialChallenge.accept(true)
    }
    
    /// Called when the biometrics prompt is shown
    public func biometricsPromptShown() {
        shouldPromptTracker = false
    }
    
    public func transitionedPastPrimaryView() {
        shouldPromptTracker = false
    }
}
