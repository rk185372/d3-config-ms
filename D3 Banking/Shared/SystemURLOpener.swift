//
//  SystemURLOpener.swift
//  D3 Banking
//
//  Created by Andrew Watt on 8/13/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import UIKit
import Utilities

final class SystemURLOpener: URLOpener {
    func open(url: URL) {
        UIApplication.shared.open(url)
    }
}
