//
//  OOBViewControllerFactory.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 12/28/20.
//

import Foundation
import PostAuthFlowController
import Localization
import ComponentKit
import Session
import UserInteraction
import CompanyAttributes

public final class OOBViewControllerFactory {
    
    private let service: OOBService
    private let config: ComponentConfig
    private let userSession: UserSession
    private let userInteraction: UserInteraction
    private let companyAttribute: CompanyAttributesHolder

    public init(service: OOBService,
                config: ComponentConfig,
                userSession: UserSession,
                userInteraction: UserInteraction,
                companyAttribute: CompanyAttributesHolder) {
        self.config = config
        self.service = service
        self.userSession = userSession
        self.userInteraction = userInteraction
        self.companyAttribute = companyAttribute
    }
    
    public func create(postAuthFlowController: PostAuthFlowController? = nil) -> OOBSetUpVerificationViewController {
        let viewController = OOBSetUpVerificationViewController(
            config: config,
            oobService: service,
            postAuthFlowController: postAuthFlowController,
            companyAttributesHolder: companyAttribute,
            userSession: userSession,
            userInteraction: userInteraction)
        return viewController
    }
}
