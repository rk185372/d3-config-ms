//
//  WatchConnectivity.swift
//  D3 Banking
//
//  Created by Branden Smith on 10/23/18.
//  Copyright © 2018 D3 Banking. All rights reserved.
//

import Foundation
import Logging
import WatchConnectivity
import Utilities

final class WatchConnectivity: NSObject, WCSessionDelegate {

    let userDefaults: UserDefaults

    let session: WCSession? = {
        guard WCSession.isSupported() else { return nil }

        return WCSession.default
    }()

    private var awaitingActivation: [() -> Void] = []

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults

        super.init()

        if let session = session {
            session.delegate = self
            session.activate()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(receivedSnapshotTokenUpdate(_:)),
            name: .snapshotTokenUpdatedNotification,
            object: nil
        )
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        log.error("session(_:didReceiveMessage:) not implemented on purpose")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {

        if !message.keys.isEmpty && message.keys.contains("userStore") {
            let responseDict = ["userStore": userDefaults.data(forKey: "AuthUserStore")]
            replyHandler(responseDict)
        }
        
        if !message.keys.isEmpty && message.keys.contains("lastSignedInUserAccount") {
            let responseDict = ["lastSignedInUserAccount": userDefaults.integer(forKey: "LastlogSignedAccount")]
            replyHandler(responseDict)
        }
        
        guard let requestedKeys = message["userDefaultKeys"] as? [String] else { return }
        var responseDict = [String: Any]()

        requestedKeys.forEach { key in
            guard let keyStoreKey = KeyStore(rawValue: key) else { return }

            responseDict[key] = userDefaults.object(key: keyStoreKey)
        }

        replyHandler(responseDict)

    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Void) {
        log.error("session(_:didReceiveMessageData:) not implemented on purpose")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        log.debug("WCSession Activation State: \(activationState)")

        if activationState == .activated {
            awaitingActivation.forEach({ $0() })
            awaitingActivation.removeAll()
        }
    }

    func sessionDidDeactivate(_ session: WCSession) {
        log.debug("WCSession deactived")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        log.debug("WCSession inactive")
    }

    @objc private func receivedSnapshotTokenUpdate(_ notification: Notification) {
        // When we have received a snapshot token update, we are going to attempt to push the
        // updated token to the watch app. We will first try to use the sendMessage(_:replyHandler:errorHandler:)
        // method to deliver the message immediately if possible. If that fails, we will try to use the
        // updateApplicationContext() method which should deliver the context update to the watch as the watch
        // has availability.
        log.debug("Snapshot token updated, sending info to watch app")
        guard let activationState = session?.activationState else { return }

        let message: [String: Any] = [
            WatchMessage.snapshotTokenUpdate: Date()
        ]

        let updateCall: () -> Void = { [weak self] in
            self?.session?.sendMessage(
                message,
                replyHandler: nil,
                errorHandler: { error in
                    log.error("Error sending message to watch", context: error)

                    // Try to deliver anyway for when the app wakes up.
                    try? self?.session?.updateApplicationContext(message)
            })
        }

        if activationState == .activated {
            updateCall()
        } else {
            self.awaitingActivation.append(updateCall)
            session?.activate()
        }
    }
}
