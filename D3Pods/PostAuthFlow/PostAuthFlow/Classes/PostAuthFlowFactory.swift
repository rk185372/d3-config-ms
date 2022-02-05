//
//  PostAuthFlowFactory.swift
//  PostAuthFlow
//
//  Created by Chris Carranza on 8/1/18.
//

import Biometrics
import CompanyAttributes
import EDocs
import Enablement
import Foundation
import Localization
import PostAuthFlowController
import SecurityQuestions
import Session
import TermsOfService
import Utilities
import OutOfBand

public final class PostAuthFlowFactory {
    private let termsOfServiceFactory: TermsOfServiceViewControllerFactory
    private let setupStepFactories: [SetupStep: PostAuthViewControllerFactory]
    private let companyAttributesHolder: CompanyAttributesHolder
    private let userDefaults: UserDefaults
    private let enableFeatureViewControllerFactory: EnableFeatureViewControllerFactory
    private let edocsViewControllerFactory: EDocsViewControllerFactory
    private let edocsConfigurationFactory: EDocsConfigurationFactory
    private let biometricsHelper: BiometricsHelper
    private let userStore: AuthUserStore
    private let oobFactory: OOBViewControllerFactory
    private let userSession: UserSession
    
    public init(termsOfServiceFactory: TermsOfServiceViewControllerFactory,
                setupStepFactories: [SetupStep: PostAuthViewControllerFactory],
                companyAttributesHolder: CompanyAttributesHolder,
                userDefaults: UserDefaults,
                enableFeatureViewControllerFactory: EnableFeatureViewControllerFactory,
                edocsViewControllerFactory: EDocsViewControllerFactory,
                edocsConfigurationFactory: EDocsConfigurationFactory,
                biometricsHelper: BiometricsHelper,
                userStore: AuthUserStore,
                oobFactory: OOBViewControllerFactory,
                userSession: UserSession) {
        self.termsOfServiceFactory = termsOfServiceFactory
        self.setupStepFactories = setupStepFactories
        self.companyAttributesHolder = companyAttributesHolder
        self.userDefaults = userDefaults
        self.enableFeatureViewControllerFactory = enableFeatureViewControllerFactory
        self.edocsViewControllerFactory = edocsViewControllerFactory
        self.edocsConfigurationFactory = edocsConfigurationFactory
        self.biometricsHelper = biometricsHelper
        self.userStore = userStore
        self.oobFactory = oobFactory
        self.userSession = userSession
    }

    public func create(termsOfService: [TermsOfService],
                       setupSteps: [SetupStep],
                       paperlessPromptAccounts: [EDocsPromptAccount],
                       estatementPromptAccounts: [EDocsPromptAccount],
                       accountNoticePromptAccounts: [EDocsPromptAccount],
                       promptForElectronicTaxDocuments: Bool,
                       l10nProvider: L10nProvider,
                       delegate: PostAuthFlowDelegate? = nil) -> PostAuthFlow {
        return PostAuthFlow(
            termsOfServiceViewControllerFactory: termsOfServiceFactory,
            termsOfService: termsOfService,
            setupStepFactories: setupStepFactories,
            setupSteps: setupSteps,
            needsBiometricsSetup: needsBiometricsSetup,
            needsSnapshotSetup: needsSnapshotSetup,
            supportedBiometricsType: biometricsHelper.supportedBiometricType,
            enableFeatureViewControllerFactory: enableFeatureViewControllerFactory,
            edocsViewControllerFactory: edocsViewControllerFactory,
            edocsConfigurationFactory: edocsConfigurationFactory,
            paperlessPromptAccounts: paperlessPromptAccounts,
            estatementPromptAccounts: estatementPromptAccounts,
            accountNoticePromptAccounts: accountNoticePromptAccounts,
            promptForElectronicTaxDocuments: promptForElectronicTaxDocuments,
            l10nProvider: l10nProvider,
            delegate: delegate,
            needsOOBSetUp: needsOOBSetUp,
            oobViewControllerFactory: oobFactory
        )
    }
    
   private var needsOOBSetUp: Bool {
      let oobVertificationEnabled =
          companyAttributesHolder.companyAttributes.value?.boolValue(forKey: "settings.security.outOfBandVerification.enabled") ?? false
      
      if (oobVertificationEnabled && self.userSession.userProfiles.contains {$0.profileType == "CONSUMER"}) {
          let userProfile = self.userSession.userProfiles.first { $0.profileType == "CONSUMER" }!
          var isEmailOutofBandExists = false
          var isMobileNumOutOfBandExists = false
          
          for item in userProfile.emailAddresses where item.outOfBand {
              isEmailOutofBandExists = true
          }
          
          for item in userProfile.phoneNumbers where item.outOfBand {
              isMobileNumOutOfBandExists = true
          }
          
          return !isEmailOutofBandExists && !isMobileNumOutOfBandExists
      }
      
      return false
    }
    
    private var needsSnapshotSetup: Bool {
        let snapshotTokenExists = userStore.snapshotToken != nil
        let hasSeenSnapshotEnablementScreen = userStore.hasPerformedSnapshotSetup

        return snapshotEnabled && !(snapshotTokenExists || hasSeenSnapshotEnablementScreen)
    }
    
    private var needsBiometricsSetup: Bool {
        let bioAuthEnabled =
            companyAttributesHolder.companyAttributes.value?.boolValue(forKey: "biometricAuthentication.enabled") ?? false
        let biometricTokenExists = biometricsHelper.tokenExists()

        return !(userDefaults.bool(key: KeyStore.performedBiometricsSetup) || biometricTokenExists)
            && bioAuthEnabled
    }
    
    private var snapshotEnabled: Bool {
        return companyAttributesHolder.companyAttributes.value?.boolValue(forKey: "bankingLogin.snapshot.enabled") ?? false
    }    
}
