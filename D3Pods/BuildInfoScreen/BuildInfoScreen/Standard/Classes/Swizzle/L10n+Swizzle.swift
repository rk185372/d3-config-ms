//
//  L10n+Swizzle.swift
//  BuildInfoScreen
//
//  Created by Branden Smith on 10/31/19.
//

import Foundation
import Localization

extension L10n {
    @objc dynamic func swizzledLocalize(_ key: String, parameterMap: [AnyHashable: Any]?) -> String {
        return key
    }

    static func swizzleLocalize() {
        let originalLocalize = class_getInstanceMethod(L10n.self, #selector(localize(_:parameterMap:)))
        let swizzledLocalize = class_getInstanceMethod(L10n.self, #selector(swizzledLocalize(_:parameterMap:)))

        method_exchangeImplementations(originalLocalize!, swizzledLocalize!)
    }
}
