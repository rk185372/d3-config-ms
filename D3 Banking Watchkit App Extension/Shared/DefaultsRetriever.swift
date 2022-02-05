//
//  DefaultsRetriever.swift
//  D3 Banking WatchKit App Extension
//
//  Created by Branden Smith on 10/22/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Dip
import Foundation
import Logging
import RxSwift
import RxCocoa
import Utilities
import WatchConnectivity

final class DefaultsRetriever: NSObject, WCSessionDelegate {
    enum Error: Swift.Error {
        case sessionNotSupported
    }

    fileprivate let _snapshotToken = BehaviorRelay<SnapshotTokenStatus>(value: .loading)
    fileprivate let _uuid = BehaviorRelay<UUIDStatus>(value: .loading)

    private var lastSignedInUserAccount: Int?
    private var lastRequestedUpdate: Date?

    override init() {
        super.init()
        WCSession.default.delegate = self
        try! retrieveDefaults()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(watchAppDidBecomeActive(_:)),
            name: .watchAppDidBecomeActive,
            object: nil
        )
    }

    private func retrieveDefaults() throws {
        _snapshotToken.accept(.loading)

        guard WCSession.isSupported() else {
            throw Error.sessionNotSupported
        }

        if WCSession.default.activationState != .activated {
            WCSession.default.activate()
        } else {
            getDefaultsFromPhone(forKeys: [KeyStore.uuid])
            getCurrentSignedInAccount()
            getSnapshotToken()
        }
    }
    
    private func getUserStore(messageKey: String, completionHandler: @escaping(AuthUserStore?) -> Void) {
        let defaults: UserDefaults = try! DependencyContainer.shared.resolve()
        
        WCSession.default.sendMessage([messageKey: true], replyHandler: { (response) in
            guard let storeData = response[messageKey] else { return }
            if messageKey == "userStore" {
                defaults.set(storeData, forKey: "AuthUserStore")
            } else if messageKey == "lastSignedInUserAccount" {
                defaults.set(storeData, forKey: "LastlogSignedAccount")
            }
            
            completionHandler(AuthUserStore(userDefaults: defaults))
        }) { (error) in
            log.error("Watch error getting user store from phone: \(error)")
            completionHandler(nil)
        }
    }
    
    // Gets the Last Signed In User account tab index from User Defaults
    private func getCurrentSignedInAccount() {
        getUserStore(messageKey: "lastSignedInUserAccount", completionHandler: { userStore in
            guard let userStore = userStore else { return }
            self.lastSignedInUserAccount = userStore.lastLoggedInAccount
            log.debug("Last Signed In Account: \(String(describing: self.lastSignedInUserAccount))")
            
            NotificationCenter.default.post(
                name: .userAccountTypeUpdated,
                object: nil,
                userInfo: ["UserAccount": self.lastSignedInUserAccount ?? 0]
            )
        })
    }

    private func getSnapshotToken() {
        getUserStore(messageKey: "userStore", completionHandler: { userStore in
            if let token = userStore?.snapshotToken {
                self._snapshotToken.accept(.token(token))
            } else {
                self._snapshotToken.accept(.noToken)
            }
        })
    }

    private func getDefaultsFromPhone(forKeys keys: [KeyStore]) {
        WCSession.default.sendMessage(
            ["userDefaultKeys": keys.map { $0.key }],
            replyHandler: { replyDictionary in
                self.saveReplyToDefaults(replyDictionary)
        }, errorHandler: { error in
            log.error("Watch error getting defaults from phone: \(error)")
        })
    }

    private func saveReplyToDefaults(_ reply: [String: Any]) {
        let defaults: UserDefaults = try! DependencyContainer.shared.resolve()

        if let uuid = reply[KeyStore.uuid.rawValue] as? String {
            _uuid.accept(.uuid(uuid))
        } else {
            _uuid.accept(.none)
        }

        reply.forEach { (key, value) in
            defaults.set(value, forKey: key)
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Swift.Error?) {
        if activationState == .activated {
            getDefaultsFromPhone(forKeys: [KeyStore.uuid])
            getCurrentSignedInAccount()
            getSnapshotToken()
        }
    }

    // This may or may not happen while the app is open
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        log.debug("Watch app received message from iPhone")
        handle(message: applicationContext)
    }

    // This should be handled immediately and will be tried first. If calling this method from
    // the application fails, the application will attempt to call session(_:didReceiveApplicationContext:)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        log.debug("Received update message from iPhone")
        handle(message: message)
    }

    private func handle(message: [String: Any]) {
        guard let requestedUpdateTime = message[WatchMessage.snapshotTokenUpdate] as? Date else { return }

        if shouldUpdate(basedOn: requestedUpdateTime) {
            self.lastRequestedUpdate = requestedUpdateTime

            try! retrieveDefaults()
        }
    }

    @objc private func watchAppDidBecomeActive(_ sender: Notification) {
        // We are not sure if there is a message here or not. If there is and it is newer than the last request
        // we will want to update right away. If it there is not or it is not newer than the last request,
        // we will check to see if the token is none. If it is, we will go ahead and to pull the token anyway
        // If they already have a token and update is not requested, there is no need to
        // check.
        let receivedUpdateMessage = WCSession.default.receivedApplicationContext[WatchMessage.snapshotTokenUpdate] as? Date

        if shouldUpdate(basedOn: receivedUpdateMessage) {
            lastRequestedUpdate = receivedUpdateMessage

            try! retrieveDefaults()
        } else if _snapshotToken.value == .noToken {
            try! retrieveDefaults()
        }
    }

    private func shouldUpdate(basedOn newRequestedTimeStamp: Date?) -> Bool {
        // If both values are Dates then true if the new is more recent
        // than old. If only the new is not nil we obviously go ahead.
        // if the new is nil we simply return false.
        switch (lastRequestedUpdate, newRequestedTimeStamp) {
        case (.some(let last), .some(let new)):
            return last.compare(new) == .orderedAscending
        case (.none, .some):
            return true
        default:
            return false
        }
    }
}

extension Reactive where Base == DefaultsRetriever {
    internal var defaultsStatus: Observable<DefaultsStatus> {
        return Observable
            .combineLatest(base._snapshotToken.asObservable(), base._uuid.asObservable())
            .map({ statuses in
                switch statuses {
                case (.token(let token), .uuid(let uuid)):
                    return .complete(snapshotToken: token, uuid: uuid)
                case (.loading, _), (_, .loading):
                    return .loading
                default:
                    return .notEnabled
                }
            })
            .distinctUntilChanged()
    }
}
