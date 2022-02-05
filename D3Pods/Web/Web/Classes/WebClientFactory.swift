//
//  WebClientFactory.swift
//  Web
//
//  Created by Andrew Watt on 7/17/18.
//

import AppInitialization
import Biometrics
import Foundation
import Network
import RxCocoa
import Session
import Utilities

public final class WebClientFactory {
    private let client: ClientProtocol
    private let device: Device
    private let userSession: UserSession
    private let biometricsHelper: BiometricsHelper
    private let userStore: AuthUserStore
    private let startupHolder: StartupHolder
    
    public init(client: ClientProtocol,
                device: Device,
                userSession: UserSession,
                biometricsHelper: BiometricsHelper,
                userStore: AuthUserStore,
                startupHolder: StartupHolder) {
        self.client = client
        self.device = device
        self.userSession = userSession
        self.biometricsHelper = biometricsHelper
        self.userStore = userStore
        self.startupHolder = startupHolder
    }

    public func create(componentPath: WebComponentPath) throws -> WebClient {
        guard let domain = client.domain.deletingAllPathComponents() else {
            throw WebError.invalidBaseUrl
        }
        
        return WebClient(
            domain: domain,
            client: client,
            device: device,
            componentPath: componentPath,
            userSession: userSession,
            biometricsHelper: biometricsHelper,
            userStore: userStore,
            startupHolder: startupHolder
        )
    }
}
