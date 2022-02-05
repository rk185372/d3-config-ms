//
//  WebViewExtensionsResponse.swift
//  Web
//
//  Created by Branden Smith on 1/30/19.
//

import Foundation

/// Usually, this would be a struct however, because there is some swizzling
/// going on in the WebViewExtensionsCache for the BuildInfoScreen. This needs
/// to be available to Objective-C therefore, it must be a class that inherits from
/// NSObject.
@objc public class WebViewExtensionsResponse: NSObject, Codable {
    public let extensions: [WebViewExtension]
    public let fonts: [String]

    public init(extensions: [WebViewExtension], fonts: [String]) {
        self.extensions = extensions
        self.fonts = fonts

        super.init()
    }

    public func toJSONString() -> String {
        let data = try! JSONEncoder().encode(self)

        return String(data: data, encoding: .utf8)!
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? WebViewExtensionsResponse else { return false }

        return self.extensions == rhs.extensions
            && self.fonts == rhs.fonts
    }
}
