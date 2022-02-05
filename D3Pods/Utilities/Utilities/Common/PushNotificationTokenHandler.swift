//
//  PushNotificationTokenHandler.swift
//  D3 Banking
//
//  Created by Branden Smith on 8/16/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation

public final class PushNotificationTokenHandler {
    public var pushId: String?

    public init(pushId: String? = nil) {
        self.pushId = pushId
    }
}
