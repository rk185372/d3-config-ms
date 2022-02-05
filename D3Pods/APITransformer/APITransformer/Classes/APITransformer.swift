//
//  APITransformer.swift
//  D3 Banking
//
//  Created by Branden Smith on 6/15/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import JavaScriptCore

public final class APITransformer {

    private let jsContext: JSContext
    private let masterProvider: MasterProvider
    private let challengeConverter: JSValue
    private let responseConverter: JSValue

    private let apiTransformerScript: String = {
        guard let pathToScript = APITransformerBundle.bundle.path(forResource: "APITransformer", ofType: "js") else {
            fatalError("Could not resolve the path to the APITransformer.js")
        }

        return try! String(contentsOfFile: pathToScript, encoding: .utf8)
    }()

    public init(l10nTranslator: L10nTranslator,
                companyAttributesProvider: CompanyAttributesProvider,
                requestSender: RequestSender) {
        masterProvider = MasterProvider(
            l10nTranslator: l10nTranslator,
            companyAttributesProvider: companyAttributesProvider,
            requestSender: requestSender
        )

        jsContext = JSContext()
        _ = jsContext.evaluateScript(apiTransformerScript)
        let module = jsContext.objectForKeyedSubscript("APITransformer")

        challengeConverter = module!.objectForKeyedSubscript("convertChallenge")
        responseConverter = module!.objectForKeyedSubscript("convertResponse")
    }

    public func serverResponseToChallengeJSON(_ jsonString: String) -> String {
        return challengeConverter.call(withArguments: [jsonString, masterProvider]).toString()
    }

    public func userResponseToServerResponse(_ jsonString: String) -> String {
        return responseConverter.call(withArguments: [jsonString]).toString()
    }
    
    public func setOOBRequestSenderDelegate(delegate: RequestSenderDelegate?) {
        masterProvider.requestSender.delegate = delegate
    }
}
