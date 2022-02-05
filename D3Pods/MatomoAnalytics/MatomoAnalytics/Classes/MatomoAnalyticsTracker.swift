//
//  PiwikAnalyticsTracker.swift
//  PiwikAnalytics
//
//  Created by Chris Carranza on 10/30/17.
//

import Foundation
import Analytics
import MatomoTracker

public final class MatomoAnalyticsTracker: AnalyticsTracker {
    private let tracker: MatomoTracker
    
    public init(url: URL, siteId: String) {
        tracker = MatomoTracker(siteId: siteId, baseURL: url)
    }
    
    public func setUserId(userId: String?) {
        tracker.userId = userId
    }
    
    public func trackScreen(_ name: String) {
        tracker.track(view: [name])
    }
    
    public func trackEvent(_ event: AnalyticsEvent) {
        tracker.track(eventWithCategory: event.category, action: event.action, name: event.name, value: event.value?.toFloat())
    }

    public func trackStartEvent(_ event: AnalyticsEvent, due: TimeInterval) {}
    public func trackEndEvent(_ event: AnalyticsEvent) {}
}
