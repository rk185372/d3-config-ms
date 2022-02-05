//
//  ScreenAnalyticsTracker.swift
//  Analytics
//
//  Created by Chris Carranza on 11/1/17.
//

import Foundation
import Aspects

/// Used to automatically track view controllers.
public final class ScreenAnalyticsTracker {
    private let tracker: AnalyticsTracker
    
    public init(tracker: AnalyticsTracker) {
        self.tracker = tracker
    }
    
    /// This will track all view controllers that conform to `TrackableScreen`.
    ///
    /// - Throws: AspectError
    public func trackViewControllers() throws {
        let wrappedBlock:@convention(block) (AspectInfo) -> Void = { aspectInfo in
            guard let trackableScreen = aspectInfo.instance() as? TrackableScreen else { return }
            
            self.tracker.trackScreen(trackableScreen.screenName)
        }
        
        try UIViewController.aspect_hook(
            #selector(UIViewController.viewDidAppear(_:)), with: .positionInstead, usingBlock: wrappedBlock
        )
    }
}
