//
//  L10nTranslator.swift
//  D3 Banking
//
//  Created by Branden Smith on 6/15/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import JavaScriptCore
import Localization

@objc protocol L10nTranslatorJSExport: JSExport {
    func translate(_ key: String, _ map: [String: Any]) -> String
}

@objc public class L10nTranslator: NSObject, L10nTranslatorJSExport {
    private let provider: L10nProvider

    public init(provider: L10nProvider) {
        self.provider = provider
    }

    func translate(_ key: String, _ map: [String: Any]) -> String {
        return provider.localize(key, parameterMap: map)
    }
}
