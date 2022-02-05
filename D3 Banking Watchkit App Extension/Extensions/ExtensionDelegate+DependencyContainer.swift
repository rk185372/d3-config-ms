//
//  ExtensionDelegate+DependencyContainer.swift
//  D3 Banking
//
//  Created by Branden Smith on 10/17/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Alamofire
import AppConfiguration
import Dip
import Foundation
import Localization
import Locations
import Network
import SnapshotService
import Utilities

extension ExtensionDelegate {
    func setupDependencyContainer() {
        DependencyContainer.shared.register(.singleton) { L10n() as L10nProvider }
        DependencyContainer.shared.register(.singleton) { UserDefaults(suiteName: AppConfiguration.applicationGroup)! }
        DependencyContainer.shared.register { D3UUID(userDefaults: $0) }
        DependencyContainer.shared.register(.singleton) { AppConfiguration.restServer }
        DependencyContainer.shared.register(.singleton) { D3WatchClientRequestAdapter(uuid: $0) as RequestAdapter }
        DependencyContainer.shared.register(.singleton) { Client(restServer: $0, requestAdapter: $1) as ClientProtocol }
        DependencyContainer.shared.register(.singleton) { SettingsServiceItem(client: $0) as SettingsService }
        DependencyContainer.shared.register(.singleton) { SnapshotServiceItem(client: $0) as SnapshotService }
        DependencyContainer.shared.register(.singleton) { LocationsServiceItem(client: $0) as LocationsService}
        DependencyContainer.shared.register(.eagerSingleton) { DefaultsRetriever() }
        DependencyContainer.shared.register(.eagerSingleton) { AuthUserStore(userDefaults: $0) }

        try! DependencyContainer.shared.bootstrap()
    }
}
