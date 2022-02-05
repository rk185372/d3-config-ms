//
//  RDCModule.swift
//  mRDC
//
//  Created by Branden Smith on 1/10/19.
//

import Foundation
import Dip
import DependencyContainerExtension
import OpenLinkManager

public final class RDCModule: DependencyContainerModule {
    public static func provideDependencies(to container: DependencyContainer) {
        container.register { RDCServiceItem(client: $0) as RDCService }
        container.register {
            RDCConfirmationViewControllerFactory(
                l10nProvider: try container.resolve(),
                componentStyleProvider: try container.resolve(),
                rdcService: try container.resolve(),
                rdcSuccessViewControllerFactory: try container.resolve(),
                rdcDepositErrorViewControllerFactory: try container.resolve(),
                pdfPresenter: try container.resolve(),
                openLinkManager: try container.resolve(),
                externalWebViewControllerFactory: try container.resolve()
            )
        }

        container.register {
            RDCCaptureProvider(
                l10nProvider: $0,
                rdcCaptureViewControllerFactory: $1,
                errorViewControllerFactory: $2
            )
        }
        container.register {
            RDCDepositViewControllerFactory(
                l10nProvider: try container.resolve(),
                componentStyleProvider: try container.resolve(),
                rdcService: try container.resolve(),
                device: try container.resolve(),
                rdcConfirmationViewControllerFactory: try container.resolve(),
                rdcCaptureProvider: try container.resolve(),
                inAppRatingManager: try container.resolve()
            )
        }
        container.register {
            RDCSuccessViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1
            )
        }
        container.register {
            RDCDepositErrorViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1
            )
        }
        container.register {
            RDCHistoryViewModel(
                rdcService: $0,
                device: $1,
                l10nProvider: $2
            )
        }
        container.register {
            RDCDepositTransactionDetailViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1,
                rdcService: $2,
                device: $3,
                rdcDepositImagesViewControllerFactory: $4
            )
        }
        container.register {
            RDCDepositImagesViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1,
                rdcZoomingImageViewControllerFactory: $2
            )
        }
        container.register {
            RDCZoomingImageViewControllerFactory(
                l10nProvider: $0,
                componentStyleProvider: $1
            )
        }
        container.register {
            RDCCameraRequiredViewControllerFactory(l10nProvider: $0, componentStyleProvider: $1)
        }

        container.register {
            RDCNavigationControllerFactory(
                companyAttributesHolder: try container.resolve(),
                l10nProvider: try container.resolve(),
                componentStyleProvider: try container.resolve(),
                rdcHistoryViewModel: try container.resolve(),
                rdcDepositTransactionDetailViewControllerFactory: try container.resolve(),
                depositViewControllerFactory: try container.resolve(),
                inAppRatingManager: try container.resolve()
            )
        }

        RDCCaptureModule.provideDependencies(to: container)
    }
}
