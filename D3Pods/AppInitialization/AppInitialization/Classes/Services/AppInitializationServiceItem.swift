//
//  AppInitializationServiceItem.swift
//  AppInitialization
//
//  Created by Branden Smith on 6/19/18.
//

import Foundation
import Network
import RxSwift
import Navigation
import CompanyAttributes
import Utilities

public final class AppInitializationServiceItem: AppInitializationService {
    private let client: ClientProtocol
    private let device: Device

    public init(client: ClientProtocol, device: Device) {
        self.client = client
        self.device = device
    }

    public func getStartup() -> Single<Decoded<Startup, String>> {
        return client.request(API.AppInitialization.loadAppConfiguration()).map { data in
            return try self.createDecodedStartup(from: data)
        }
    }

    public func updateStartup() -> Single<Decoded<Startup, String>> {
        return client.request(API.AppInitialization.updateAppConfiguration()).map { data in
            return try self.createDecodedStartup(from: data)
        }
    }
    
    public func checkForUpgrades() -> Single<UpgradeNotification?> {
        return client.request(API.AppInitialization.upgradeCheck(device: device)).map { response in
            return response.upgradeNotification
        }
    }

    private func createDecodedStartup(from data: Data) throws -> Decoded<Startup, String> {
        let response = try JSONDecoder().decode(StartupResponse.self, from: data)
        guard let json = String(data: data, encoding: .utf8) else {
            throw AppInitializationError.decoding
        }
        let companyAttributes = CompanyAttributes(dictionary: response.settings)
        let startup = Startup(companyAttributes: companyAttributes)

        return Decoded(value: startup, source: json)
    }
}

enum AppInitializationError: Error, CustomStringConvertible {
    case decoding
    
    var description: String {
        switch self {
        case .decoding:
            return "Could not decode JSON"
        }
    }
}
