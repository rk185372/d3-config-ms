//
//  RawSession.swift
//  Session
//
//  Created by Andrew Watt on 10/9/18.
//

import Foundation
import TermsOfService
import EDocs

public struct RawSession: Codable, Equatable {
    public var activeProfileType: String
    public var csrfToken: String
    public var estatementPromptAccounts: [EDocsPromptAccount]?
    public var paperlessPromptAccounts: [EDocsPromptAccount]?
    public var accountNoticePromptAccounts: [EDocsPromptAccount]?
    public var promptForElectronicTaxDocuments: Bool?
    public var profiles: [UserProfile]
    public var rdcAllowed: Bool
    public var serverTime: String
    public var startupKey: Int
    public var syncOps: [ProfileSyncOperation]?
    public var tos: [TermsOfService]?
    public var setupSteps: [SetupStep]?
    public var validProfileTypes: [String]
    public var userDeviceId: Int?
    public var systemNotification: SystemNotification?

    public var selectedProfileIndex: Int {
        didSet {
            // Whenever we set the Profile Index we need to also update the activeProfileType to match so that they're in sync
            self.activeProfileType = profiles[selectedProfileIndex].profileType
        }
    }
}

extension RawSession {
    public func copyClearingSetupSteps() -> RawSession {
        return RawSession(
            activeProfileType: self.activeProfileType,
            csrfToken: self.csrfToken,
            estatementPromptAccounts: [],
            paperlessPromptAccounts: [],
            accountNoticePromptAccounts: [],
            promptForElectronicTaxDocuments: false,
            profiles: self.profiles,
            rdcAllowed: self.rdcAllowed,
            serverTime: self.serverTime,
            startupKey: self.startupKey,
            syncOps: self.syncOps,
            tos: [],
            setupSteps: [],
            validProfileTypes: self.validProfileTypes,
            userDeviceId: self.userDeviceId,
            systemNotification: self.systemNotification,
            selectedProfileIndex: self.selectedProfileIndex
        )
    }
}
