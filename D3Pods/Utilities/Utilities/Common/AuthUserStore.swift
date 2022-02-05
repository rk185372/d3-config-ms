//
//  AuthUserStore.swift
//  Utilities
//
//  Created by Elvin Bearden on 12/9/20.
//

import Foundation
import Logging

public class AuthUserStore {
    public class UserData: Codable {
        public let username: String
        public var isCurrentUser: Bool
        public var isBiometricUser: Bool
        public var isPersonalAccount: Bool

        var snapshotToken: String?
        var hasPerformedSnapshotSetup: Bool
        var hasSeenFeatureTour: Bool

        public var isTemporary: Bool

        public init(username: String,
                    isCurrentUser: Bool = true,
                    isTemporary: Bool = false,
                    isBiometricUser: Bool = false,
                    isPersonalAccount: Bool = false) {
            self.username = username
            self.isCurrentUser = isCurrentUser
            self.snapshotToken = nil
            self.hasPerformedSnapshotSetup = false
            self.hasSeenFeatureTour = false
            self.isTemporary = isTemporary
            self.isBiometricUser = isBiometricUser
            self.isPersonalAccount = isPersonalAccount
        }
    }

    private let storeKey = "AuthUserStore"
    private let userDefaults: UserDefaults
    private var userStore: [String: UserData] = [:]
    public var lastlogSignedAccountKey = "LastlogSignedAccount"

    public var currentUserData: UserData? {
        return userStore
            .map { $0.1 }
            .first(where: { $0.isCurrentUser && $0.isPersonalAccount })
    }
    
    public var currentBusinessUserData: UserData? {
        return userStore
            .map { $0.1 }
            .first(where: { $0.isCurrentUser && !$0.isPersonalAccount })
    }

    private var anyCurrentUserData: UserData? {
        return userStore
            .map { $0.1 }
            .first(where: { $0.isCurrentUser })
    }

    public var currentUsername: String? {
        guard let currentUser = currentUserData else { return nil }
        guard !currentUser.isTemporary && currentUser.isPersonalAccount else { return nil }
        return currentUser.username
    }
    
    public var currentBusinessUsername: String? {
        guard let currentUser = currentBusinessUserData else { return nil }
        guard !currentUser.isTemporary && !currentUser.isPersonalAccount else { return nil }
        return currentUser.username
    }

    public var savedUsernames: [String] {
        return userStore
            .filter { !$0.value.isTemporary && $0.value.isPersonalAccount }
            .keys.map { $0 }
            .sorted()
    }
    
    public var savedBusinessUsernames: [String] {
        return userStore
            .filter { !$0.value.isTemporary && !$0.value.isPersonalAccount }
            .keys.map { $0 }
            .sorted()
    }

    // NOTE: This can be removed or edited if we want to support multiple user tokens
    public var snapshotToken: String? {
        return userDefaults.string(forKey: "snapshotToken") ??
            userStore
                .map { $0.1 }
                .first(where: { $0.snapshotToken != nil })?.snapshotToken
    }

    // NOTE: This can be removed or edited if we want to support multiple user tokens
    public var hasPerformedSnapshotSetup: Bool {
        return userDefaults.bool(forKey: "performedSnapshotSetup") ||
            !userStore
                .map { $0.1 }
                .filter { $0.hasPerformedSnapshotSetup }
                .isEmpty
    }
    // NOTE: This can be removed or edited if we want to support different settings per user
    public var hasSeenFeatureTour: Bool {
        return !userStore
            .map { $0.1 }
            .filter { $0.hasSeenFeatureTour }
            .isEmpty
    }

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
    }

    public func userData(for username: String) -> UserData? {
        return userStore[username]
    }

    public func setSnapshotToken(_ token: String?) {
        guard let user = anyCurrentUserData else { return }
        user.snapshotToken = token
        save()
    }

    public func setHasPerformedSnapshotSetup() {
        guard let user = anyCurrentUserData else { return }
        user.hasPerformedSnapshotSetup = true
        save()
    }

    public func setHasSeenFeatureTour() {
        guard let user = anyCurrentUserData else { return }
        user.hasSeenFeatureTour = true
        save()
    }

    public func setCurrentUser(userData: UserData) {
        userStore
            .filter { $0.value.isPersonalAccount == userData.isPersonalAccount }
            .values
            .forEach { $0.isCurrentUser = false }
        userData.isCurrentUser = true
        save()
    }

    public func setBiometricUser(userData: UserData) {
        userStore.values.forEach { $0.isBiometricUser = false }
        userData.isBiometricUser = true
        save()
    }

    public func saveUserData(_ userData: UserData) {
        userStore[userData.username] = userData
        save()
    }

    public func deleteUserData(_ userData: UserData) {
        userStore.removeValue(forKey: userData.username)
        save()
    }

    public func deleteUserData(for username: String) {
        userStore.removeValue(forKey: username)
        save()
    }

    private func save() {
        guard let json = try? JSONEncoder().encode(userStore) else {
            log.error("Failed to save AuthUserData")
            return
        }
        userDefaults.set(json, forKey: storeKey)
    }

    private func load() {
        guard let data = userDefaults.data(forKey: storeKey) else { return }

        do {
            self.userStore = try JSONDecoder().decode([String: UserData].self, from: data)
        } catch {
            log.error("Failed to load AuthUserData")
        }
    }
    
    public func saveLastloginAccount(lastLoginAccountTabIndex: Int) {
        userDefaults.set(lastLoginAccountTabIndex, forKey: lastlogSignedAccountKey)
    }
    
    public var lastLoggedInAccount: Int {
        let data = userDefaults.integer(forKey: lastlogSignedAccountKey)
        return data 
    }
}
