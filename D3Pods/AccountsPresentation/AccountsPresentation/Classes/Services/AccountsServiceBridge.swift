//
//  AccountsServiceBridge.swift
//  AccountsPresentation
//
//  Created by Branden Smith on 10/17/19.
//

import D3Accounts
import Foundation
import JavaScriptCore

final class AccountsServiceBridge {
    private let jsContext: JSContext
    private let accountsListConverter: JSValue
    
    let accountsListTransformerScript: String = {
        guard let pathToScript = AccountsPresentationBundle.bundle.path(forResource: "AccountsListTransformer", ofType: "js") else {
            fatalError("Could not resolve the path to the AccountsListTransformer.js")
        }

        return try! String(contentsOfFile: pathToScript, encoding: .utf8)
    }()

    init() {
        jsContext = JSContext()
        _ = jsContext.evaluateScript(accountsListTransformerScript)

        let module = jsContext.objectForKeyedSubscript("AccountsListTransformer")
        accountsListConverter = module!.objectForKeyedSubscript("convertAccounts")
    }

    func convert(serverResponse response: AccountsListResponse) -> [AccountSection] {
        let json = try! JSONEncoder().encode(response)
        let jsonString = String(data: json, encoding: .utf8)!

        let convertedString = accountsListConverter.call(withArguments: [jsonString])!.toString()!
        let convertedJSON = convertedString.data(using: .utf8)!

        let response = try! JSONDecoder().decode(ConvertedAccountsListResponse.self, from: convertedJSON)

        return response.accountSections
    }
}
