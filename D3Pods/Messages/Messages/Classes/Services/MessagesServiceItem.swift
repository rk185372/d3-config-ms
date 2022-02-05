//
//  MessagesServiceItem.swift
//  Messages
//
//  Created by Branden Smith on 9/6/18.
//

import Foundation
import Network
import RxSwift

public final class MessagesServiceItem: MessagesService {
    let client: ClientProtocol

    public init(client: ClientProtocol) {
        self.client = client
    }

    public func getAlertsStats() -> Single<AlertsStats> {
        return client.request(API.Messages.getAlertsStats())
    }

    public func getSecureMessageStats() -> Single<SecureMessageStats> {
        return client.request(API.Messages.getSecureMessageStats())
    }
    
    public func getApprovalsStats() -> Single<ApprovalsStats> {
        return client.request(API.Messages.getApprovalStats())
    }
}
