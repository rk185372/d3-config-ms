//
//  ApplicationRoot.swift
//  D3 Banking
//
//  Created by Andrew Watt on 8/3/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import Navigation
import Web

/// The composition root of the dependency container graph
struct ApplicationRoot {
    var rootPresenter: RootPresenter
    var notificationListener: NotificationListener

    // swiftlint:disable:next weak_delegate
    var pushNotificationDelegate: AppPushNotificationDelegate
}
