//
//  Keychain+D3.swift
//  D3 Banking
//
//  Created by Chris Carranza on 4/18/17.
//  Copyright © 2017 D3 Banking. All rights reserved.
//

import Foundation
import KeychainAccess

extension Keychain {
    /// Keychain singleton. Initializes with the apps bundle identifier.
    static let shared: Keychain = Keychain()
}
