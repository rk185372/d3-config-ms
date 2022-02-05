//
//  CompositeAnalyticsTracker.swift
//  Analytics
//
//  Created by Chris Carranza on 2/8/19.
//

import Foundation

public final class CompositeAnalyticsTracker: AnalyticsTracker {

    private let trackers: [AnalyticsTracker]
    
    public init(trackers: [AnalyticsTracker]) {
        self.trackers = trackers
    }
    
    public func setUserId(userId: String?) {
        trackers.forEach { $0.setUserId(userId: userId) }
    }
    
    public func trackScreen(_ name: String) {
        trackers.forEach { $0.trackScreen(name) }
    }
    
    public func trackEvent(_ event: AnalyticsEvent) {
        trackers.forEach { $0.trackEvent(event) }
    }

    public func trackStartEvent(_ event: AnalyticsEvent, due: TimeInterval) {
        trackers.forEach { $0.trackStartEvent(event, due: due) }
    }

    public func trackEndEvent(_ event: AnalyticsEvent) {
        trackers.forEach { $0.trackEndEvent(event) }
    }

}
