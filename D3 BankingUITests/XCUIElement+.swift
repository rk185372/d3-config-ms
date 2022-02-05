//
//  XCUIElement+.swift
//  D3 BankingUITests
//
//  Created by Chris Carranza on 3/13/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElement {
    /// Wait for element to exist with a default timeout of 8 seconds
    ///
    /// - Returns: true if element exists, false if it doesn't
    func waitForExistence() -> Bool {
        return waitForExistence(timeout: 60)
    }
    
    /// Focuses the field first then types into it
    ///
    /// - Parameter text: the text to type
    func focusAndType(_ text: String) {
        tap()
        typeText(text)
    }
}
