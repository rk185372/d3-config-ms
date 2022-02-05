//
//  LogAnalyticsTracker.swift
//  LogAnalytics
//
//  Created by Chris Carranza on 10/31/17.
//

import Foundation
import Analytics
import Logging

public final class LogAnalyticsTracker: AnalyticsTracker {
    
    public init() {}
    
    public func trackScreen(_ name: String) {
        log.debug("[Screen Track]: \(name)")
    }
    
    public func trackEvent(_ event: AnalyticsEvent) {
        log.debug("[Event Track]: \(event)")
    }

    public func trackStartEvent(_ event: AnalyticsEvent, due: TimeInterval) {
        log.debug("[Start Event Track]: \(event)")
    }

    public func trackEndEvent(_ event: AnalyticsEvent) {
        log.debug("[End Event Track]: \(event)")
    }
    
    // Do not implement, we do not want to log the user id as it could end up being
    // reported to the crash reporting tools.
    public func setUserId(userId: String?) {}
}
