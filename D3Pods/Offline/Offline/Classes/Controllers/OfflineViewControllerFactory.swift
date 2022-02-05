//
//  OfflineViewControllerFactory.swift
//  Offline
//
//  Created by Andrew Watt on 9/24/18.
//

import UIKit
import ComponentKit

public final class OfflineViewControllerFactory {
    private let config: ComponentConfig
    private let monitor: ReachabilityMonitor?
    
    public init(config: ComponentConfig, monitor: ReachabilityMonitor?) {
        self.config = config
        self.monitor = monitor
    }
    
    public func create() -> OfflineViewController {
        return OfflineViewController(config: config, monitor: monitor)
    }
}
