//
//  ChallengePresenterFactory.swift
//  Authentication
//
//  Created by Chris Carranza on 6/26/18.
//

import Foundation
import ComponentKit
import Localization
import ViewPresentable
import CompanyAttributes

final class ChallengePresenterFactory {
    private let challenge: ChallengeResponse
    private let componentStyleProvider: ComponentStyleProvider
    private let personalChallenges: [ChallengeItem]
    private let businessChallenges: [ChallengeItem]
    private let personalActionChallenges: [ChallengeAction]
    private let businessActionChallenges: [ChallengeAction]
    private let personalLinkButtons: [ChallengeItem]
    private let businessLinkButtons: [ChallengeItem]
    private let tabSegment: [ChallengeItem]
    private let l10nProvider: L10nProvider
    
    private let persistenceHelper: ChallengePersistenceHelper
    private let companyAttributesHolder: CompanyAttributesHolder
    
    init(challenge: ChallengeResponse,
         componentStyleProvider: ComponentStyleProvider,
         l10nProvider: L10nProvider,
         persistenceHelper: ChallengePersistenceHelper,
         companyAttributesHolder: CompanyAttributesHolder) {
        self.challenge = challenge
        self.componentStyleProvider = componentStyleProvider
        self.l10nProvider = l10nProvider
        self.tabSegment = challenge.items.filter { $0 as? ChallengeTabSegmentItems != nil }
        // Personal Challenges
        self.personalChallenges = challenge.items.filter {
            $0 as? ChallengeLinkButtonItems == nil &&
                $0 as? ChallengeTabSegmentItems == nil &&
                $0 as? ChallengeBusinessToolTipItems == nil &&
                ($0.tabIndex == nil || $0.tabIndex == 0)
        }
        
        // Business Challenges
        self.businessChallenges = challenge.items.filter {
            $0 as? ChallengeLinkButtonItems == nil &&
                $0 as? ChallengeTabSegmentItems == nil &&
                $0 as? ChallengeBusinessToolTipItems == nil &&
                ($0.tabIndex == nil || $0.tabIndex == 1 )
        }
        
        // Action items for (Personal - Tab Index = 0, Business - Tab Index = 1)
        self.personalActionChallenges = challenge.actions.filter {
            ($0 as ChallengeAction).tabIndex == nil ||
            ($0 as ChallengeAction).tabIndex == 0 }
        self.businessActionChallenges = challenge.actions.filter {
            ($0 as ChallengeAction).tabIndex == nil ||
            ($0 as ChallengeAction).tabIndex == 1
        }
        // Action items
        self.personalLinkButtons = challenge.items.filter { $0 as? ChallengeLinkButtonItems != nil &&
            (($0 as? ChallengeLinkButtonItems)?.tabIndex == 0)
        }
        self.businessLinkButtons = challenge.items.filter { $0 as? ChallengeLinkButtonItems != nil &&
            (($0 as? ChallengeLinkButtonItems)?.tabIndex == 1)
        }
        self.persistenceHelper = persistenceHelper
        self.companyAttributesHolder = companyAttributesHolder
    }
    
    func titlePresenters() -> [ChallengeTitlePresenter] {
        return challenge
            .titles
            .filter({ !$0.titleType.isMessage })
            .map({
                ChallengeTitlePresenter(challengeTitle: $0, componentStyleProvider: componentStyleProvider)
            })
    }
    
    func message() -> ChallengeTitle? {
        return challenge
            .titles
            .filter({ $0.titleType.isMessage })
            .first
    }
    
    func tabSegmentPresenters(currentTabIndex: Int) -> [ChallengeTabSegmentPresenter] {
        return tabSegment.map {
            switch $0 {
            case let item as ChallengeTabSegmentItems:
                return ChallengeTabSegmentPresenter(
                    challenge: item,
                    selectedTabSegmentIndex: currentTabIndex,
                    l10nProvider: self.l10nProvider
                )
            default:
                fatalError("I have encountered a challengeItem that isn't a tab segment or has no presenter")
            }
        }
    }
    
    // Get Item Presenters based on Tab Index
    // 0 - Personal
    // 1 - Business
    func itemPresenters(withTabIndex: Int) -> [AnyViewPresentable] {
        switch withTabIndex {
        case 0:
            return getPresenters(challengeItems: self.personalChallenges)
        case 1:
            return getPresenters(challengeItems: self.businessChallenges)
        default:
            fatalError("I have encountered a challengeItem that isn't a tab segment or has no presenter")
        }
    }
    
    func getPresenters(challengeItems: [ChallengeItem]) -> [AnyViewPresentable] {
        return challengeItems.map {
            switch $0 {
            case let item as ChallengeTextInputItem:
                return AnyViewPresentable(ChallengeTextInputPresenter(
                    challenge: item,
                    componentStyleProvider: componentStyleProvider,
                    persistenceHelper: persistenceHelper
                ))
            case let item as ChallengeCheckboxItem:
                // MARK: Update key when real one is availables
                return AnyViewPresentable(ChallengeCheckboxPresenter(challenge: item,
                                                                     persistenceHelper: persistenceHelper))
            case let item as ChallengeRadioButtonItem:
                return AnyViewPresentable(
                    ChallengeRadioButtonItemPresenter(challenge: item, componentStyleProvider: componentStyleProvider)
                )
            case let item as ChallengeNewQuestionItem:
                return AnyViewPresentable(ChallengeNewQuestionItemPresenter(
                    challenge: item,
                    componentStyleProvider: componentStyleProvider
                ))
            default:
                // There are some challenge items that are not presentable such as the
                // ChallengeDeviceTokenItem. We want to make sure these are stripped from the
                // challenge before getting to this point.
                fatalError("I have encountered a challengeItem that isn't a Personal Account or Business Account")
            }
        }
    }
    
    func actionPresenters(withTabIndex: Int) -> [ChallengeActionPresenter] {
        switch withTabIndex {
        case 0:
            return self.personalActionChallenges.map {
                ChallengeActionPresenter(challenge: $0, componentStyleProvider: componentStyleProvider)
            }
        case 1:
            return self.businessActionChallenges.map {
                ChallengeActionPresenter(challenge: $0, componentStyleProvider: componentStyleProvider)
            }
        default:
            // There are some challenge items that are not presentable such as the
            // ChallengeDeviceTokenItem. We want to make sure these are stripped from the
            // challenge before getting to this point.
            fatalError("I have encountered a challengeItem that isn't a Personal Account or Business Account")
        }
    }
    
    func linkButtonPresenters(withTabIndex: Int) -> [ChallengeLinkButtonItemsPresenter] {
        switch withTabIndex {
        case 0:
            return getLinkButtonPresenters(linkButtonItems: self.personalLinkButtons)
        case 1:
            return getLinkButtonPresenters(linkButtonItems: self.businessLinkButtons)
        default:
            fatalError("I have encountered a challengeItem that isn't a Personal Account or Business Account")
        }
    }
    
    func getLinkButtonPresenters(linkButtonItems: [ChallengeItem]) -> [ChallengeLinkButtonItemsPresenter] {
        return linkButtonItems.map {
            switch $0 {
            case let item as ChallengeLinkButtonItems:
                return ChallengeLinkButtonItemsPresenter(
                    challenge: item,
                    componentStyleProvider: componentStyleProvider
                )
            default:
                fatalError("I have encountered a challengeItem that isn't a link button or has no presenter")
            }
        }
    }
}
