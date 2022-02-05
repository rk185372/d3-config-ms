//
//  FirebaseAnalyticsTracker.swift
//  FirebaseAnalyticsD3
//
//  Created by Chris Carranza on 2/18/19.
//

import Foundation
import Analytics
import FirebaseAnalytics

public final class FirebaseAnalyticsTracker: AnalyticsTracker {
    
    public init() {}
    
    public func trackScreen(_ name: String) {
        Analytics.setScreenName(name, screenClass: nil)
    }
    
    public func trackEvent(_ event: AnalyticsEvent) {
        var params = [
            AnalyticsParameterItemName: event.name,
            AnalyticsParameterContentType: event.action
        ]
        
        if let id = event.value {
            params[AnalyticsParameterItemID] = "\(id)"
        }
        
        Analytics
            .logEvent(AnalyticsEventSelectContent, parameters: params)
    }

    public func trackStartEvent(_ event: AnalyticsEvent, due: TimeInterval) {}
    public func trackEndEvent(_ event: AnalyticsEvent) {}
    
    // Do not implement, we do not want to log the user id as it could end up being
    // reported to the crash reporting tools.
    public func setUserId(userId: String?) {}
}
