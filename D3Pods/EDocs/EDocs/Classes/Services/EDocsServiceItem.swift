//
//  EDocsServiceItem.swift
//  EDocs
//
//  Created by Branden Smith on 12/8/17.
//

import Foundation
import Network
import RxSwift

public final class EDocsServiceItem: EDocsService {
    private let client: ClientProtocol
    
    public init(client: ClientProtocol) {
        self.client = client
    }
    


    public func updateEDocPreferences(request: UpdateDeliverySettings,
                                      confirmationConfig: EDocsConfirmationConfiguration) -> Single<EDocsNetworkResult> {
        return client
            .request(API.EDocs.updateEDocPreferences(request: request))
            .map({ _ -> EDocsNetworkResult in
                // This response will essentially be ignored since we only plan on knowing if there was
                // a network success or failure here.
                let edocsResponse = EDocsResponse(accounts: [])

                return .success(response: edocsResponse, confirmationConfig: confirmationConfig)
            })
            .catchErrorJustReturn(.failure(confirmationConfig: confirmationConfig))
    }

    public func declineEDocs(for type: EDocsDocumentType) -> Single<Void> {
        return client.request(API.EDocs.declineEDocs(for: type))
    }
}
