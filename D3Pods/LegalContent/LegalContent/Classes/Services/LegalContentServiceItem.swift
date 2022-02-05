//
//  LegalContentServiceItem.swift
//  LegalContent
//
//  Created by Chris Carranza on 5/22/18.
//

import Foundation
import Network
import RxSwift

public final class LegalContentServiceItem: LegalContentService {
    private let client: ClientProtocol
    
    public init(client: ClientProtocol) {
        self.client = client
    }
    
    public func retrieveDisclosure(legalServiceType: LegalServiceType) -> Single<DisclosureResponse> {
        return client.request(API.LegalContent.retreiveDisclosure(legalServiceType: legalServiceType))
    }
}
