//
//  SnapshotViewControllerFactory.swift
//  Snapshot
//
//  Created by Andrew Watt on 8/14/18.
//

import ComponentKit
import Foundation
import SnapshotService
import Utilities
import CompanyAttributes
import Web

public final class SnapshotViewControllerFactory {
    private let config: ComponentConfig
    private let service: SnapshotService
    private let device: Device
    private let configurationSettings: ConfigurationSettings

    public init(config: ComponentConfig, service: SnapshotService, device: Device, configurationSettings: ConfigurationSettings) {
        self.config = config
        self.service = service
        self.device = device
        self.configurationSettings = configurationSettings
    }
    
    public func create(token: String) -> UIViewController {
        let viewModel = SnapshotViewModel(service: service, token: token, uuid: device.uuid)
        return SnapshotViewController(config: config, viewModel: viewModel, factory: self,configurationSettings: configurationSettings)
    }

    public func createDetail(viewModel: SnapshotViewModel) -> UIViewController {
        return SnapshotDetailViewController(config: config, viewModel: viewModel)
    }
}
