//
//  CompanyAttributesProvider.swift
//  D3 Banking
//
//  Created by Branden Smith on 6/15/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import CompanyAttributes
import JavaScriptCore
import Foundation
import Utilities

@objc protocol CompanyAttributesProviderJSExport: JSExport {
    func boolValueFor(_ key: String) -> Bool
    func stringValueFor(_ key: String) -> String
    func intValueFor(_ key: String) -> Int
}

@objc public class CompanyAttributesProvider: NSObject, CompanyAttributesProviderJSExport {
    private let holder: CompanyAttributesHolder
    private var companyAttributes: CompanyAttributes? {
        return holder.companyAttributes.value
    }
    
    public init(companyAttributesHolder holder: CompanyAttributesHolder) {
        self.holder = holder
        super.init()
    }
    
    func boolValueFor(_ key: String) -> Bool {
        return companyAttributes?.value(forKey: key) ?? false
    }

    func stringValueFor(_ key: String) -> String {
        return companyAttributes?.value(forKey: key) ?? ""
    }

    func intValueFor(_ key: String) -> Int {
        return companyAttributes?.value(forKey: key) ?? 0
    }
}
