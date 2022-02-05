//
//  RequestSender.swift
//
//  Created by Branden Smith on 6/20/18.
//  Copyright © 2018 Branden Smith. All rights reserved.
//

import Foundation
import JavaScriptCore

@objc public protocol RequestSenderDelegate {
    func requestSender(_: RequestSender, hasOOBChallenge challenge: String)
}

@objc public protocol RequestSenderJSExport: JSExport {
    func performOOBRequest(_ challenge: String)
}

@objc public class RequestSender: NSObject, RequestSenderJSExport {
    
    public weak var delegate: RequestSenderDelegate?
    
    public override init() {
        super.init()
    }
    
    public func performOOBRequest(_ challenge: String) {
        delegate?.requestSender(self, hasOOBChallenge: challenge)
    }
}
