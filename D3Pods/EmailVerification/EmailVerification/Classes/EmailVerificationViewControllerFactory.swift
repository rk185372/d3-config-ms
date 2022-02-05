//
//  EmailVerificationsViewControllerFactory.swift
//  EmailVerifications
//
//  Created by Pablo Pellegrino on 10/6/21.
//

import CompanyAttributes
import ComponentKit
import Foundation
import Localization
import Logging
import PostAuthFlowController
import Session
import Utilities

public final class EmailVerificationViewControllerFactory: PostAuthViewControllerFactory {
    private let l10nProvider: L10nProvider
    private let styleProvider: ComponentStyleProvider
    private let serviceItem: EmailVerificationService
    private let session: UserSession
    
    public init(l10nProvider: L10nProvider,
                componentStyleProvider: ComponentStyleProvider,
                serviceItem: EmailVerificationService,
                session: UserSession) {
        self.l10nProvider = l10nProvider
        self.styleProvider = componentStyleProvider
        self.serviceItem = serviceItem
        self.session = session
    }

    public func create(postAuthFlowController: PostAuthFlowController) -> UIViewController {
        if let primaryEmail = self.primaryEmail {
            return EmailNotificationViewController(serviceItem: serviceItem,
                                                   l10nProvider: l10nProvider,
                                                   componentStyleProvider: styleProvider,
                                                   postAuthFlowController: postAuthFlowController,
                                                   currentEmail: primaryEmail)
        }
        return EmailVerificationViewController(
            serviceItem: serviceItem,
            l10nProvider: l10nProvider,
            componentStyleProvider: styleProvider,
            postAuthFlowController: postAuthFlowController
        )
    }
}

private extension EmailVerificationViewControllerFactory {
    var primaryEmail: String? {
        return session.selectedProfile?.emailAddresses.first { $0.primary }?.value
    }
    
}
