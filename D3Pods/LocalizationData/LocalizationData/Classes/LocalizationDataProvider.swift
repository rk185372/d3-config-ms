//
//  LocalizationDataProvider.swift
//  LocalizationData
//
//  Created by Branden Smith on 2/8/19.
//

import Foundation

public final class LocalizationDataProvider {

    public init() {}
    
    // Consumer Localizable data
    public func ConsumerLocalizableData () -> [String: Any] {
        
        let url = LocalizationDataBundle.bundle.url(forResource: "Localizable", withExtension: "json")!
        let contents = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: contents) as! [String: Any]

        return json
    }
    
    // Busness Localizable Data
    public func BusinessLocalizableData() -> [String: Any] {
        let url = LocalizationDataBundle.bundle.url(forResource: "BusinessLocalizable", withExtension: "json")!
        let contents = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(with: contents) as! [String: Any]

        return json
    }
}
