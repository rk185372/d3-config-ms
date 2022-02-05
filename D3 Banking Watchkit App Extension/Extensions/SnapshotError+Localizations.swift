//
//  SnapshotError+Localizations.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/23/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import SnapshotService

extension SnapshotError {
    var errorLocalizedKey: String {
        if case let .sync(value) = self {
            switch value {
            case .pending:
                return "launchPage.snapshot.status-active"
            case .success:
                return "launchPage.snapshot.status-complete-success"
            default:
                return "launchPage.snapshot.unexpected-error"
            }
        } else {
            return "launchPage.snapshot.unexpected-error"
        }
    }
}
