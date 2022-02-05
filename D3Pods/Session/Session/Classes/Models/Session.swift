//
//  Session.swift
//  Session
//
//  Created by Andrew Watt on 7/6/18.
//

import EDocs
import Foundation
import TermsOfService

public struct Session: Equatable {
    public var activeProfileType: String
    public var csrfToken: String
    public var estatementPromptAccounts: [EDocsPromptAccount]?
    public var paperlessPromptAccounts: [EDocsPromptAccount]?
    public var accountNoticePromptAccounts: [EDocsPromptAccount]?
    public var promptForElectronicTaxDocuments: Bool
    public var rdcAllowed: Bool
    public var selectedProfileIndex: Int
    public var serverTime: String
    public var startupKey: Int
    public var syncOps: [ProfileSyncOperation]?
    public var tos: [TermsOfService]?
    public var setupSteps: [SetupStep]?
    public var validProfileTypes: [String]
    public var userDeviceId: Int?
    public var systemNotification: SystemNotification?

    public init(from raw: RawSession) {
        self.activeProfileType = raw.activeProfileType
        self.csrfToken = raw.csrfToken
        self.estatementPromptAccounts = raw.estatementPromptAccounts
        self.paperlessPromptAccounts = raw.paperlessPromptAccounts
        self.accountNoticePromptAccounts = raw.accountNoticePromptAccounts
        self.promptForElectronicTaxDocuments = raw.promptForElectronicTaxDocuments ?? false
        self.rdcAllowed = raw.rdcAllowed
        self.selectedProfileIndex = raw.selectedProfileIndex
        self.serverTime = raw.serverTime
        self.startupKey = raw.startupKey
        self.syncOps = raw.syncOps
        self.tos = raw.tos
        self.setupSteps = raw.setupSteps
        self.validProfileTypes = raw.validProfileTypes
        self.userDeviceId = raw.userDeviceId
        self.systemNotification = raw.systemNotification
    }
}
