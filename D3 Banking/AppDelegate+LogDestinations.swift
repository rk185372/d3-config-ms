//
//  AppDelegate+LogDestinations.swift
//  D3 Banking
//
//  Created by Branden Smith on 11/29/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import FirebaseCrashlytics
import Foundation
import Logging
import SwiftyBeaver

extension AppDelegate {
    func getOSLogDestination() -> OSLogDestination {
        let destination = OSLogDestination()
        destination.minLevel = .warning

        return destination
    }

    func getConsoleDestination() -> ConsoleDestination {
        let destination = ConsoleDestination()
        destination.asynchronously = false
        destination.minLevel = .verbose
        destination.levelColor.verbose = "💁🏻‍♂️ "
        destination.levelColor.debug = "🐞 "
        destination.levelColor.info = "🤔 "
        destination.levelColor.warning = "☢️ "
        destination.levelColor.error = "🛑 "

        return destination
    }

    func getCrashlyticsDestination(crashlytics: Crashlytics) -> CrashlyticsDestination {
        let destination = CrashlyticsDestination(crashlytics: crashlytics)
        destination.minLevel = .debug

        return destination
    }
}
