//
//  TestL10n.swift
//  D3 Banking
//
//  Created by Chris Carranza on 3/19/19.
//  Copyright © 2019 D3 Banking. All rights reserved.
//

import Foundation
import Localization
import RxSwift
import Network

final class TestL10n: L10nProvider {
    
    private let bag = DisposeBag()
    
    private var localizations: [String: String] = [:]
    
    init(client: ClientProtocol) {
        client
            .request(Endpoint<[String: Any]>(path: "l10n/json"))
            .subscribe(onSuccess: { [unowned self] dict in
                self.loadLocalizations(resources: dict, completion: nil)
            }, onError: { (error) in
                fatalError("Error Getting L10n: \(error)")
            })
            .disposed(by: bag)
    }

    func loadLocalizations(resources: [String: Any], completion: ((Error?) -> Void)?) {
        localizations = resources.mapValues { item in
            return item as! String
        }
    }
    
    func localize(_ key: String) -> String {
        return localizations[key] ?? key
    }
    
    func localize(_ key: String, parameterMap: [AnyHashable: Any]?) -> String {
        return localize(key)
    }

}
