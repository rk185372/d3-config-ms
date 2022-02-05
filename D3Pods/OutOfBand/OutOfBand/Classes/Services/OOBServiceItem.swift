//
//  OOBServiceItem.swift
//  OutOfBand
//
//  Created by Padmanabhuni Bhaskaruni, Nagasri Sai Swetha on 12/29/20.
//

import Foundation
import Network
import Utilities
import RxSwift
import Session

public final class OOBServiceItem: OOBService {
    
    private let client: ClientProtocol
    private let device: Device
    
    public init(client: ClientProtocol, device: Device) {
        self.client = client
        self.device = device
    }
    
    public func putOutOfBandDestinations(userProfile: UserProfile) -> Single<Void> {
        return client.request(API.OobDestinations.putOutOfBandDestinations(request: userProfile))
    }
}
