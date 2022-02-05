//
//  AppInitializationService.swift
//  AppInitialization
//
//  Created by Branden Smith on 6/19/18.
//

import Foundation
import Network
import RxSwift
import Navigation
import Utilities

public protocol AppInitializationService {
    func getStartup() -> Single<Decoded<Startup, String>>
    func updateStartup() -> Single<Decoded<Startup, String>>
    func checkForUpgrades() -> Single<UpgradeNotification?>
}
