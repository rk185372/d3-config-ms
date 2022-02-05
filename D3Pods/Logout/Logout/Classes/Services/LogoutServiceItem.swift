//
//  LogoutServiceItem.swift
//  Logout
//
//  Created by Chris Carranza on 9/13/18.
//

import Foundation
import RxSwift
import Network

public final class LogoutServiceItem: LogoutService {
    private let client: ClientProtocol
    
    public init(client: ClientProtocol) {
        self.client = client
    }
    
    public func logout() -> Completable {
        return client.request(API.Logout.logout()).asCompletable()
    }
}
