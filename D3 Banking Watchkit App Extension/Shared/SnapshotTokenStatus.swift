//
//  SnapshotTokenStatus.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 4/17/20.
//  Copyright © 2020 D3 Banking. All rights reserved.
//

import Foundation

public enum SnapshotTokenStatus: Equatable {
    case loading
    case token(String)
    case noToken
}
