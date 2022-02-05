//
//  WebClient.swift
//  Web
//
//  Created by Andrew Watt on 7/17/18.
//

import AppInitialization
import Biometrics
import Foundation
import Logging
import Network
import RxCocoa
import RxSwift
import Session
import Utilities

public class WebClient {
    public let domain: URL
    public let client: ClientProtocol
    public let device: Device
    public let componentPath: WebComponentPath
    public let userSession: UserSession
    public let biometricsHelper: BiometricsHelper
    public let userStore: AuthUserStore
    public let startupHolder: StartupHolder

    public var deviceJSON: String? {
        do {
            let data = try JSONEncoder().encode(device)
            return try String(jsonData: data)
        } catch {
            log.error("Error encoding device: \(error)", context: error)
            return nil
        }
    }

    public var sessionJSON: String? {
        guard let rawSession = userSession.rawSession else {
            return nil
        }
        do {
            let data = try JSONEncoder().encode(rawSession)
            return try String(jsonData: data)
        } catch {
            log.error("Error encoding session: \(error)", context: error)
            return nil
        }
    }
    
    public var startupJSON: String? {
        return startupHolder.decodedStartup?.source
    }

    /// The host of the `WebClient`'s domain.
    public var domainHost: String? {
        return self.domain.host
    }

    /// The url in which a web view should navigate.
    /// # Note
    ///     This property is dynamic so that it can be swizzled when necessary. Changing this property
    ///     to be non-dynamic will cause any swizzling to fail. Before changing, ensure that the
    ///     selector: #selector(getter: navigationURL) is not being used anywhere inside of the app or any
    ///     of the pods that are dependent on the Web pod.
    @objc public dynamic var navigationURL: URL {
        guard let baseUrl = Bundle.main.url(forResource: "webComponents", withExtension: nil) else {
            log.error("webComponents missing")
            fatalError()
        }

        return URL(string: "\(baseUrl)index.html#\(componentPath.path)")!
    }

    public var navigationURLDescription: String {
        return navigationURL
            .absoluteString
            .drop { $0 != "#" }
            .lowercased()
    }
    
    public init(domain: URL,
                client: ClientProtocol,
                device: Device,
                componentPath: WebComponentPath,
                userSession: UserSession,
                biometricsHelper: BiometricsHelper,
                userStore: AuthUserStore,
                startupHolder: StartupHolder) {
    self.domain = domain
    self.client = client
    self.device = device
    self.componentPath = componentPath
    self.userSession = userSession
    self.biometricsHelper = biometricsHelper
    self.userStore = userStore
    self.startupHolder = startupHolder
}
    
    public func updateUserProfile(fromDictionary dictionary: [String: Any], at index: Int) {
        guard userSession.userProfiles.indices.contains(index) else { return }

        do {
            let userProfile = try DictionaryDecoder().decode(UserProfile.self, from: dictionary)
            userSession.userProfiles[index] = userProfile
        } catch {
            log.error("Error updating user profile: \(error)", context: error)
        }
    }
}
