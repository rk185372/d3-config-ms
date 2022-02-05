//
//  BiometricsHelper.swift
//  Biometrics
//
//  Created by Chris Carranza on 8/16/18.
//

import Foundation
import CompanyAttributes
import BiometricKeychainAccess
import DeviceInfoService
import Utilities
import RxSwift
import RxRelay
import Network

public enum SupportedBiometricType {
    case none
    case touchId
    case faceId
}

public protocol BiometricsHelper {
    var biometricAuthEnabled: Bool { get }
    var biometricAuthNeedsEnabled: Bool { get }
    var domainStateChanged: Bool { get }
    var supportedBiometricType: SupportedBiometricType { get }
    func tokenExists() -> Bool
    func retrieveToken() -> Single<String>
    func optInBiometricAuth() -> Completable
    func optOutBiometricAuth() -> Completable
    func updateToken(token: String) throws
    func updateServerTokenStatus() -> Single<Bool>
    func removeToken() throws
}

public final class BiometricsHelperItem: BiometricsHelper {
    public typealias Error = BiometricKeychainAccess.Error
    
    private let companyAttributes: CompanyAttributesHolder
    private let keychainAccess: BiometricKeychainAccess
    private let deviceInfoService: DeviceInfoService
    private let biometricsService: BiometricsService
    private let application: UIApplication
    private let userDefaults: UserDefaults
    private let userStore: AuthUserStore

    private var serverTokenExists: Bool = false
    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    
    private var serverBiometricAuthenticationEnabled: Bool {
        return companyAttributes.companyAttributes.value?.boolValue(forKey: "biometricAuthentication.enabled") ?? false
    }
    
    public var biometricAuthEnabled: Bool {
        return tokenExists()
            && keychainAccess.biometricsAvailable
            && serverBiometricAuthenticationEnabled
    }
    
    public var biometricAuthNeedsEnabled: Bool {
        return !tokenExists()
            && keychainAccess.biometricsAvailable
            && serverBiometricAuthenticationEnabled
            && userDefaults.bool(key: KeyStore.performedBiometricsSetup)
    }
    
    public var domainStateChanged: Bool {
        return keychainAccess.domainStateChanged
    }
    public var supportedBiometricType: SupportedBiometricType {
        if !keychainAccess.biometricsAvailable {
            return .none
        } else if keychainAccess.faceIdAvailable {
            return .faceId
        } else {
            return .touchId
        }
    }
    
    init(companyAttributes: CompanyAttributesHolder,
         keychainAccess: BiometricKeychainAccess,
         deviceInfoService: DeviceInfoService,
         biometricsService: BiometricsService,
         application: UIApplication,
         userDefaults: UserDefaults,
         userStore: AuthUserStore) {
        self.companyAttributes = companyAttributes
        self.keychainAccess = keychainAccess
        self.deviceInfoService = deviceInfoService
        self.biometricsService = biometricsService
        self.application = application
        self.userDefaults = userDefaults
        self.userStore = userStore
    }

    public func tokenExists() -> Bool {
        return self.keychainAccess.tokenExists()
    }

    public func retrieveToken() -> Single<String> {
        return Single.create { observer in
            self.keychainAccess
                .getTokenWithPrompt(handler: { (result) in
                    switch result {
                    case .success(let token):
                        observer(.success(token))
                    case .failure(let error):
                        observer(.error(error))
                    }
                })
            
            return Disposables.create {}
        }
    }
    
    /// Enrolls user in biometric authentication. Will store the token on a successfull
    /// enrollment.
    ///
    /// - Returns: Completable
    public func optInBiometricAuth() -> Completable {
        return deviceInfoService
            .getDeviceInfo()
            .flatMap { deviceInfoResponse in
                self.biometricsService.optInBiometricAuth(deviceId: deviceInfoResponse.id)
            }
            .do(onSuccess: { enableResponse in
                try self.updateToken(token: enableResponse.token)
                guard let user = self.userStore.currentUserData else { return }
                self.userStore.setBiometricUser(userData: user)
            })
            .asCompletable()
    }
    
    /// Disenrolls the user in biometric authentication by first removing the local token,
    /// then contacting the server to remove the remote token.
    ///
    /// - Returns: Completable
    public func optOutBiometricAuth() -> Completable {
        return deviceInfoService
            .getDeviceInfo()
            .flatMap({ (deviceInfoResponse) -> Single<DisableResponse> in
                self.biometricsService.optOutBiometricAuth(deviceId: deviceInfoResponse.id)
            })
            .do(onSuccess: { disableResponse in
                if !disableResponse.keepToken {
                    do {
                        try self.keychainAccess.removeToken()
                    } catch {}
                }
            })
            .asCompletable()
    }

    public func updateToken(token: String) throws {
        try self.keychainAccess.removeToken()
        try self.keychainAccess.setToken(token)
        self.keychainAccess.updateEvaluatedPolicyDomainState()
        self.userDefaults.set(value: true, key: KeyStore.performedBiometricsSetup)
    }

    public func removeToken() throws {
        try self.keychainAccess.removeToken()
    }

    public func updateServerTokenStatus() -> Single<Bool> {
        if tokenExists(), !userDefaults.bool(key: KeyStore.performedBiometricsSetup) {
            try? self.removeToken()
        }
        
        return deviceInfoService
            .getServerBiometricAuthToken()
            .do(onSuccess: { [weak self] status in
                self?.serverTokenExists = (status == .tokenExists)

                // If we get a response saying the token does not exist
                // (this can also happend with a 404 respnose) we want to clear
                // any token saved on the device.
                if status == .tokenDoesNotExist {
                    try? self?.removeToken()
                }
            })
            .map({ $0 == .tokenExists })

    }
    
    private func requestBackgroundExecution() {
        guard UIBackgroundTaskIdentifier.invalid == backgroundTaskId else { return }
        backgroundTaskId = application.beginBackgroundTask(expirationHandler: {
            self.endBackgroundExecution()
        })
    }
    
    private func endBackgroundExecution() {
        guard UIBackgroundTaskIdentifier.invalid != backgroundTaskId else { return }
        application.endBackgroundTask(backgroundTaskId)
        backgroundTaskId = .invalid
    }
}
