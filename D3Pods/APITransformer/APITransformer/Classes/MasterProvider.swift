//
//  MasterProvider.swift
//  D3 Banking
//
//  Created by Branden Smith on 6/15/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc protocol MasterProviderJSExport: JSExport {
    var l10nTranslator: L10nTranslator { get set }
    var companyAttributesProvider: CompanyAttributesProvider { get set }
    var requestSender: RequestSender { get set }
}

@objc class MasterProvider: NSObject, MasterProviderJSExport {
    @objc dynamic var l10nTranslator: L10nTranslator
    @objc dynamic var companyAttributesProvider: CompanyAttributesProvider
    @objc dynamic var requestSender: RequestSender

    init(l10nTranslator: L10nTranslator,
         companyAttributesProvider: CompanyAttributesProvider,
         requestSender: RequestSender) {
        self.l10nTranslator = l10nTranslator
        self.companyAttributesProvider = companyAttributesProvider
        self.requestSender = requestSender
    }
}
