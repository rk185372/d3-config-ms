//
//  AnalyticsTracker.swift
//  Analytics
//
//  Created by Chris Carranza on 10/30/17.
//

import Foundation

public protocol AnalyticsTracker {
    func setUserId(userId: String?)
    func trackScreen(_ name: String)
    func trackEvent(_ event: AnalyticsEvent)
    func trackStartEvent(_ event: AnalyticsEvent, due: TimeInterval)
    func trackEndEvent(_ event: AnalyticsEvent)
}
