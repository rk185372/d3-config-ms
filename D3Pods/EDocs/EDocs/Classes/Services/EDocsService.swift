//
//  EDocsService.swift
//  EDocs
//
//  Created by Chris Carranza on 4/12/18.
//

import Foundation
import Logging
import RxSwift
import Utilities

public protocol EDocsService {
    // These two are used for the updated edocs preferences.
    func updateEDocPreferences(request: UpdateDeliverySettings,
                               confirmationConfig: EDocsConfirmationConfiguration) -> Single<EDocsNetworkResult>
    func declineEDocs(for type: EDocsDocumentType) -> Single<Void>
}


