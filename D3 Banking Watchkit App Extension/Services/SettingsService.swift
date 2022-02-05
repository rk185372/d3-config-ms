//
//  SettingsService.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/18/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import CompanyAttributes
import Foundation
import Network
import RxSwift

protocol SettingsService {
    func getSettings() -> Single<CompanyAttributes>
}

final class SettingsServiceItem: SettingsService {

    private let client: ClientProtocol

    init(client: ClientProtocol) {
        self.client = client
    }

    func getSettings() -> Single<CompanyAttributes> {
        return client.request(API.WatchSettings.getSettings()).map { settingsResponse in
            var companyAttributes = settingsResponse.settings

            if let customerServiceNumber = settingsResponse.resources["watch.customer-service.phone-number"] as? String {
                companyAttributes["watch.customer-service.phone-number"] = customerServiceNumber
            }

            return CompanyAttributes(dictionary: companyAttributes)
        }
    }
}
