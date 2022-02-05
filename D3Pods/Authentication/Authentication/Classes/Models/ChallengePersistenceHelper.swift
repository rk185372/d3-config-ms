//
//  ChallengePersistenceHelper.swift
//  Authentication
//
//  Created by Branden Smith on 8/7/18.
//

import Foundation
import Utilities
import CompanyAttributes
import Biometrics

final class ChallengePersistenceHelper {
    private let authUserStore: AuthUserStore
    private let companyAttributesHolder: CompanyAttributesHolder
    private let biometricsHelper: BiometricsHelper
    
    var enableBiometrics: Bool {
        return biometricsHelper.biometricAuthEnabled
    }
    
    init(authUserStore: AuthUserStore,
         companyAttributesHolder: CompanyAttributesHolder,
         biometricsHelper: BiometricsHelper) {
        self.authUserStore = authUserStore
        self.companyAttributesHolder = companyAttributesHolder
        self.biometricsHelper = biometricsHelper
    }
    
    func persistFields(in challengeItems: [ChallengeItem], currentTabIndex: Int, activeProfileTypeIndex: Int) {
        if (currentTabIndex == 0) {
            guard let shouldSaveUsername = challengeItems
                .first(where: { $0.challengeName == ChallengeName.saveUsername.rawValue }) as? ChallengeCheckboxItem else { return }
            guard let usernameField = challengeItems
                .first(where: { $0.challengeName == ChallengeName.username.rawValue }) as? ChallengeTextInputItem else { return }
            guard let username = usernameField.value  else { return }
            guard shouldSaveUsername.value else {
                saveTempUserName(username: username, activeProfileTypeIndex: activeProfileTypeIndex)
                return
            }
            
            saveUsername(username: username,
                         currentTabIndex: currentTabIndex,
                         activeProfileTypeIndex: activeProfileTypeIndex)
        } else if (currentTabIndex == 1) {
            
            guard let shouldSaveBusinessUsername = challengeItems
                .first(where: { $0.challengeName == ChallengeName.saveBusinessUsername.rawValue }) as? ChallengeCheckboxItem else { return }
            guard let businessUsernameField = challengeItems
                .first(where: { $0.challengeName == ChallengeName.business_username.rawValue }) as? ChallengeTextInputItem else { return }
            guard let businessUsername = businessUsernameField.value  else { return }
            guard shouldSaveBusinessUsername.value else {
                saveTempUserName(username: businessUsername, activeProfileTypeIndex: activeProfileTypeIndex)
                return
            }
            
            saveUsername(username: businessUsername,
                         currentTabIndex: currentTabIndex,
                         activeProfileTypeIndex: activeProfileTypeIndex)
        }
    }
    
    func saveTempUserName(username: String?, activeProfileTypeIndex: Int?) {
        guard username != nil, !savedUserLimitReached else { return }

        if let user = authUserStore.userData(for: username!) {
            user.isTemporary = true
            user.isPersonalAccount = activeProfileTypeIndex == 0
            authUserStore.saveUserData(user)
        } else {
            let user = AuthUserStore.UserData(
                username: username!,
                isTemporary: true,
                isPersonalAccount: activeProfileTypeIndex == 0
            )
            authUserStore.saveUserData(user)
        }
    }
    
    func populateFields(in challengeItems: [ChallengeItem]) {
        guard let usernameField = challengeItems
            .first(where: { $0.challengeName == ChallengeName.username.rawValue }) as? ChallengeTextInputItem else { return }
        guard let saveUsernameField = challengeItems
            .first(where: { $0.challengeName == ChallengeName.saveUsername.rawValue }) as? ChallengeCheckboxItem else { return }
        
        if let username = authUserStore.currentUsername {
            saveUsernameField.value = true
            usernameField.value = username
            usernameField.maskedValue = username.masked()
        } else if let username = savedUsernames(currentTabIndex: 0).first {
            saveUsernameField.value = true
            usernameField.value = username
            usernameField.maskedValue = username.masked()
        } else {
            saveUsernameField.value = false
        }
        
        guard let businessUsernameField = challengeItems
            .first(where: { $0.challengeName == ChallengeName.business_username.rawValue }) as? ChallengeTextInputItem else { return }
        guard let saveBusinessUsernameField = challengeItems
            .first(where: { $0.challengeName == ChallengeName.saveBusinessUsername.rawValue }) as? ChallengeCheckboxItem else { return }
        
        if let business_username = authUserStore.currentBusinessUsername {
            saveBusinessUsernameField.value = true
            businessUsernameField.value = business_username
            businessUsernameField.maskedValue = business_username.masked()
        } else if let business_username = savedUsernames(currentTabIndex: 1).first {
            saveBusinessUsernameField.value = true
            businessUsernameField.value = business_username
            businessUsernameField.maskedValue = business_username.masked()
        } else {
            saveBusinessUsernameField.value = false
        }
    }
    
    func savedUsernames(currentTabIndex: Int) -> [String] {
        if(currentTabIndex == 0) {
            return authUserStore.savedUsernames
        } else {
            return authUserStore.savedBusinessUsernames
        }
    }
    
    func saveUsername(username: String, currentTabIndex: Int, activeProfileTypeIndex: Int) {
        if savedUserLimitReached { return }
        if let userData = authUserStore.userData(for: username) {
            userData.isTemporary = false
            userData.isPersonalAccount = activeProfileTypeIndex == 0
            authUserStore.setCurrentUser(userData: userData)
        } else {
            let userData = AuthUserStore.UserData(username: username)
            userData.isPersonalAccount = activeProfileTypeIndex == 0
            authUserStore.saveUserData(userData)
            authUserStore.setCurrentUser(userData: userData)
        }
    }
    
    func totalSavedUsernames() -> [String] {
        return authUserStore.savedUsernames + authUserStore.savedBusinessUsernames
    }

    func numberOfSavedUsers() -> Int {
        if totalSavedUsernames().isEmpty {
            return 0
        }
        return totalSavedUsernames().count
    }
    
    func deleteUsername(username: String) {
        authUserStore.deleteUserData(for: username)
    }
    
    func persistCurrentTabIndex(currentTabIndex: Int) {
        authUserStore.saveLastloginAccount(lastLoginAccountTabIndex: currentTabIndex)
    }
    
    func loadCurrentTabIndex() -> Int {
        return authUserStore.lastLoggedInAccount
    }
}

extension ChallengePersistenceHelper {
    var maxSavedUsers: Int {
        return companyAttributesHolder.companyAttributes.value?.value(forKey: "consumerAuthentication.change.username.saved.limit") ?? 3
    }
    
    var savedUserLimitReached: Bool {
        let limit = maxSavedUsers
        return 0 < limit && limit <= numberOfSavedUsers()
    }
}
