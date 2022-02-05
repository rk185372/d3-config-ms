//
//  ReachabilityMonitor.swift
//  Offline
//
//  Created by Andrew Watt on 9/24/18.
//

import Foundation
import Alamofire
import Logging
import Network
import RxSwift
import RxCocoa
import Utilities
import AppConfiguration

public final class ReachabilityMonitor {
    public static let debounceInterval: DispatchTimeInterval = .seconds(2)
    
    private let statusRelay: BehaviorRelay<NetworkReachabilityManager.NetworkReachabilityStatus>
    private let manager: NetworkReachabilityManager?
    
    public var status: Driver<NetworkReachabilityManager.NetworkReachabilityStatus> {
        return statusRelay.asDriver().distinctUntilChanged()
    }
    
    public init?(host: String?) {
        guard let manager = NetworkReachabilityManager(host: host) else {
            log.error("Unable to create NetworkReachabilityManager for host: \(host ?? "nil")")
            return nil
        }
        
        self.statusRelay = BehaviorRelay(value: manager.networkReachabilityStatus)
        self.manager = manager
        
        manager.listener = { (status) in
            log.debug("Reachability changed to: \(status)")
            self.statusRelay.accept(status)
        }
        manager.startListening()
    }

    public convenience init?(restServer: RestServer) {
        self.init(host: restServer.url.host)
    }
}
