//
//  TermsOfServiceServiceItem.swift
//  TermsOfService
//
//  Created by Chris Carranza on 4/5/18.
//

import Foundation
import Network
import RxSwift
import Utilities

public final class TermsOfServiceServiceItem: TermsOfServiceService {
    
    private let client: ClientProtocol
    private let device: Device
    
    public init(client: ClientProtocol, device: Device) {
        self.client = client
        self.device = device
    }
    
    public func accept(termsOfService: TermsOfService) -> Single<Void> {
        return client.request(API.TermsOfService.accept(service: termsOfService.service, parameters: device.dictionary()))
    }
}
