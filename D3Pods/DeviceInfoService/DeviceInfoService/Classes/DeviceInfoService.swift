//
//  DeviceInfoService.swift
//  DeviceInfoService
//
//  Created by Chris Carranza on 8/15/18.
//

import Alamofire
import Foundation
import Network
import RxSwift
import Utilities

public final class DeviceInfoService {
    public enum ServerBiometricAuthTokenResponseStatus {
        // The server has an existing token related to the
        // device uuid.
        case tokenExists

        // The server returns a 404 not found indicating that
        // it has no biometric auth token for the given uuuid.
        case tokenDoesNotExist

        // The server returned an error other than a 404.
        case unknownError
    }
    
    private let client: ClientProtocol
    private let uuid: D3UUID
    
    public init(client: ClientProtocol, uuid: D3UUID) {
        self.client = client
        self.uuid = uuid
    }

    /// Checks the server for the existence of a biometric token and maps the result to a
    /// ServerBiometricAuthTokenResponseStatus. This single should not error because any errors
    /// are mapped to a specfic status to be handled by the caller.
    public func getServerBiometricAuthToken() -> Single<ServerBiometricAuthTokenResponseStatus> {
        return client
            .request(API.DeviceInfo.getDeviceInfoUnauthenticated(uuid: uuid.uuidString))
            .map({ deviceInfoResponse in
                return deviceInfoResponse.authTokenExists
                    ? .tokenExists
                    : .tokenDoesNotExist
            }).catchError({ error in
                return Single.create { observer in
                    // In response to a 404 error we want to indicate that the server does not have a
                    // biometric auth token so that we can remove any existing token on the device.
                    // If an error other than a 404 is returned we don't know that the server doesn't have a
                    // token so we return unknownError indicating that an existing biometric auth token should
                    // not be removed. 
                    if case AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 404)) = error {
                        observer(.success(.tokenDoesNotExist))
                    } else {
                        observer(.success(.unknownError))
                    }

                    return Disposables.create()
                }
            })
    }
    
    public func getDeviceInfo() -> Single<DeviceInfoResponse> {
        return client.request(API.DeviceInfo.getDeviceInfo(uuid: uuid.uuidString))
    }
}
