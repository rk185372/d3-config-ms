//
//  SessionService.swift
//  Session
//
//  Created by Andrew Watt on 7/6/18.
//

import Foundation
import Network
import Utilities
import RxSwift

public class SessionService {
    private let client: ClientProtocol
    private let device: Device
    private let userSession: UserSession
    private let tokenHandler: PushNotificationTokenHandler
    
    public init(client: ClientProtocol,
                device: Device,
                userSession: UserSession,
                pushNotificationTokenHandler: PushNotificationTokenHandler) {
        self.client = client
        self.device = device
        self.userSession = userSession
        self.tokenHandler = pushNotificationTokenHandler
    }
    
    public func getSession() -> Single<RawSession> {
        let endpoint = API.Session.session(device: device, tokenHandler: tokenHandler)
        return self.client.request(endpoint)
    }
    
    /// If no session is set, this method calls `getSession` to establish the session, sets
    /// it, and returns a `UserSession` object. If the session is already set, this
    /// method simply returns the already stored `UserSession` object.
    ///
    /// - returns: a `Single` that will emit the session when it is available.
    public func ensureSession() -> Single<UserSession> {
        if userSession.rawSession != nil {
            return Single.just(userSession)
        } else {
            return getSession()
                .do(onSuccess: { (session) in
                    self.userSession.rawSession = session
                })
                .map { _ in self.userSession }
        }
    }
    
    public func clearSession() -> Completable {
        return Completable.create { event in
            self.userSession.rawSession = nil
            event(.completed)
            
            return Disposables.create {}
        }
    }
}

enum SessionError: Error, CustomStringConvertible {
    case decoding
    case encoding
    
    var description: String {
        switch self {
        case .decoding:
            return "Could not decode session JSON"
        case .encoding:
            return "Could not encode session JSON"
        }
    }
}
