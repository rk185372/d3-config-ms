//
//  SecurityQuestionsViewControllerFactory.swift
//  SecurityQuestions
//
//  Created by Branden Smith on 12/3/18.
//

import CompanyAttributes
import ComponentKit
import Foundation
import Localization
import Logging
import PostAuthFlowController
import Utilities

public final class SecurityQuestionsViewControllerFactory: PostAuthViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let styleProvider: ComponentStyleProvider
    private let serviceItem: SecurityQuestionsService
    private let companyAttributesHolder: CompanyAttributesHolder
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                serviceItem: SecurityQuestionsService,
                companyAttributesHolder: CompanyAttributesHolder) {
        self.l10nProvider = l10nProvider
        self.styleProvider = componentStyleProvider
        self.serviceItem = serviceItem
        self.companyAttributesHolder = companyAttributesHolder
    }

    public func create(postAuthFlowController: PostAuthFlowController) -> UIViewController {
        return SecurityQuestionsViewController(
            serviceItem: serviceItem,
            l10nProvider: l10nProvider,
            componentStyleProvider: styleProvider,
            companyAttributesHolder: companyAttributesHolder,
            postAuthFlowController: postAuthFlowController
        )
    }
}
